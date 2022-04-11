#!/bin/bash

# usage:
# % bash mk_pypack_macos.sh
#
# This script extracts the library ids of the dynamic libraries (*.dylib)
# found in the library files and accordingly adjusts the library paths
# referring to the external libraries (like `libfftw3.dylib`) in the given libraries.
# The script searches also for dependencies up to the 2nd order and adds
# them to the external libraries.
#
# For instance,
# % bash mk_pypack_macos.sh
# finds the dynamic libraries (*.dylib) in `.../lib/extra` folder, and
# adjusts the library reference paths in each given library file.
#
# Requires MacOS-specific native tools `otool` and `install_name_tool`.

# See further:
# - Runtime linking on Mac <https://matthew-brett.github.io/docosx/mac_runtime_link.html>
# - Apple developer documentation: 'Run-Path Dependent Libraries' <https://apple.co/3HVbMWm>
# - Loading Dynamic Libraries on Mac <http://clarkkromenaker.com/post/library-dynamic-loading-mac>
# - <https://stackoverflow.com/q/66268814>
# - dlopen manpage

# NOTE:
# - MacPorts:
# By default, MacPorts installs libraries under `/opt/local` (see <https://guide.macports.org>)
# Using
# % port contents qt5-qtbase
# it is found that the Qt root folder is `/opt/local/libexec/qt5`.
# - Homebrew:
# By default, Homebrew installs libraries under `/usr/local/opt/` and `/usr/local/Cellar` (see <https://docs.brew.sh/Manpage>)
# Qt default installation folder will be:
#   $HOMEBREW_PREFIX/opt/qt@5
#   $HOMEBREW_PREFIX/opt/qt5
#   $HOMEBREW_PREFIX/Cellar/qt@5/
# The variable `HOMEBREW_PREFIX` can be found via
# % brew config | grep HOMEBREW_PREFIX
# by default, HOMEBREW_PREFIX='/usr/local'.
# To obtain the value of the config variable use:
# % brew config | sed -nE 's;.*HOMEBREW_PREFIX:[[:blank:]]*(.+)[[:blank:]]*;\1;p'

# externally given variables
pyoutdir="@BA_PY_OUTPUT_DIR@"
libdir="@BA_PY_LIBRARY_OUTPUT_DIR@"
xlibdir="@BA_PY_EXTRA_LIBRARY_OUTPUT_DIR@"
wheeldir="@BA_PY_PACKAGE_WHEEL_DIR@"
PYTHON="@__Py3_EXECUTABLE@"

# constants
TITLE="MacOS RPATHs"
HELP="$TITLE: Usage: bash mk_pypack_macos.sh"
COPY="/bin/cp -vnf"

# absolute source directory
if [ -z $libdir ]
then
    echo "$TITLE: Error: Provide the directory for the main libraries."
    echo "$HELP"
    exit 1
fi

if [ -z $xlibdir ]
then
    echo "$TITLE: Error: Provide the directory for the external libraries."
    echo "$HELP"
    exit 1
fi

# list of the main library files
libfiles="$libdir/*.so"

# turn logging off (0), log to stdout (1)
LOG_FLAG=1
LOG_TOKEN=".:"
# separator line for output
SEPLINE="=========="

echo "$TITLE: library directories = '$libdir', '$xlibdir'"
#-- functions

# Qt default paths
brew1="/usr/local/opt"
brew2="/opt/homebrew/opt"
port1="/opt/local/libexec"
qt_rpaths="$brew1/qt@5/  $brew1/qt5/  $brew2/qt@5  $brew2/qt5  $port1/qt5"

# NOTE: `echo ... >&2` is used for logging inside functions
function log()
{
    if [[ $LOG_FLAG == 1 ]]; then
        echo "$LOG_TOKEN $1" >&2
    fi
}

# use otool to get the base id of a library (raw output)
function dylib_base_id()
{
    local libnm=$1
    # otool output example:
    # ```
    # cmd LC_ID_DYLIB
    # cmdsize 56
    # name @rpath/_libFooSample.1.so (offset 24)
    # ```
    # eg. 'name @rpath/libA.1.so (offset 24)' => 'libA.1.so'
    local lib_id_re='s;.+name[[:blank:]]+.+/(.+)[[:blank:]]+\(.+;\1;p'
    # return the base library id
    otool -l "$libnm" | grep -A2 -F LC_ID_DYLIB | sed -nE $lib_id_re
}

# use otool to get the 1st-order dependencies of a library (raw output)
function dylib_deps()
{
    local libnm=$1
    # obtain the dependencies; remove the first line which is
    # the name of the file itself
    # otool output example: '   /usr/local/opt/foo.dylib (compatibility ...)'
    otool -L "$libnm" | tail -n +2
}

function rm_list_duplicates()
{
    lst=$@
    # remove duplicates from a given list (separator is a blank char)
    echo $lst | tr ' ' '\n' | sort -u | tr '\n' ' '
}

# get dependencies of a given library on BA libraries
function get_BA_depends()
{
    local libnm=$1
    # obtain the dependencies; remove the first line which is
    # the name of the file itself; find lines containing '/opt/' or '/Cellar/'
    echo dylib_deps "$libnm" | grep -F 'libBA'
}

# get 1st-order dependencies for a given file
function get_depends1()
{
    local libnm=$1
    # obtain the dependencies; remove the first line which is
    # the name of the file itself; find lines containing '/opt/' or '/Cellar/'
    local optional_deps_re='/(opt|Cellar)/'
    local _deps=$(dylib_deps "$libnm" | grep -E $optional_deps_re)
    # make a clean list of dependencies without duplicates
    # eg. '  /usr/local/opt/foo.dylib (compatibility ...)' => '/usr/local/opt/foo.dylib'
    local path_re='s;[[:blank:]]*([^@].+)[[:blank:]]+\(.+;\1;p'
    echo "$_deps" | sort -u | sed -nE $path_re
}

# get Python dependence for a given file
function get_python_dependence()
{
    local libnm=$1
    # extract the Python dependency from the given file
    # regexp to extract the Python dependence
    py_fmwk_re='s;[[:blank:]]*([^@].+)/(Python|libpython.+\.dylib).*;\1/\2;p'
    # regexp to correct the Python dependence; eg.:
    # '/usr/local/opt/python@3.9/Frameworks/Python.framework/Versions/3.9/Python' => 'libpython3.9.dylib'
    # '/usr/local/opt/python@3.9/Frameworks/Python.framework/Versions/3.9/libpython3.9.dylib' => 'libpython3.9.dylib'
    pylib_re='s;.*[pP]ython.+[Vv]ersions/([0-9.]+).+(Python|libpython).*;libpython\1.dylib;'
    # obtain the dependencies; remove the first line which is
    # the name of the file itself
    pydeps0=$(dylib_deps "$libnm")
    pydepends_fullpath=$(echo "$pydeps0" | sed -nE $py_fmwk_re)
    pydepends_filename=$(echo "$pydepends_fullpath" | sed -E $pylib_re)

    # return the Python dependence fullpath and filename
    echo "$pydepends_fullpath  $pydepends_filename"
}


# get Python dependence for a given file
function get_python_framework_path()
{
    local pydepends_fullpath=$1
    # regexp to extract the Python framework path
    # eg.: '/usr/local/opt/python@3.9/Frameworks/Python.framework/Versions/3.9/Python'
    #   => '/usr/local/opt/python@3.9/Frameworks/Python.framework/Versions/3.9/'
    py_fmwk_path_re='s;(.*)/(Python|libpython).*;\1;'
    # regexp to extract the Python version
    pyversion_re='s;.*[pP]ython.+[Vv]ersions/([0-9.]+).*;\1;'
    # obtain the dependencies; remove the first line which is
    # the name of the file itself
    pyversion=$(echo "$pydepends_fullpath" | sed -E $pyversion_re)
    py_fmwk_dir=$(echo "$pydepends_fullpath" | sed -E $py_fmwk_path_re)
    # add RPATHs corresponding to the common framework paths
    framework_paths="/usr/local/Library/Frameworks  /Library/Frameworks  /usr/local/Frameworks"
    py_fmwk_path="Python.framework/Versions/$pyversion/lib"
    # when the library is like '.../Versions/3.9/Python', then
    # add an extra '/lib' to the framework path.
    # This is needed since refer always to the Python shared library
    # '.../Versions/3.9/lib/libpython39.dylib'.
    if [[ $pydepends_fullpath = */Python ]]; then
        py_fmwk_dir="$py_fmwk_dir/lib"
    fi
    py_fmwk_rpaths="$py_fmwk_dir"
    for pth in $framework_paths; do
        py_fmwk_rpaths="$py_fmwk_rpaths  $pth/$py_fmwk_path"
    done
    # return a list of possible framework paths
    echo $py_fmwk_rpaths
}


# get dependencies up to 2nd order for a given file
function get_depends()
{
    local deps0 dep dep1 deps2 deps_all deps_all_sep
    #-- obtain the 1st-order dependencies of the given file
    deps0=$(get_depends1 "$1")
    log "* Direct dependencies of '$1':"
    for dep in $deps0
    do
        log "+ $dep"
    done
    #-- find 2nd-order dependencies
    # for each 1st-order dependency, find 1st-order dependencies
    for dep1 in $deps0
    do
        deps2=$(get_depends1 "$dep1")
        # add dependencies to the list of all dependencies
        deps_all="$deps_all  $dep1  $deps2"
    done
    log $SEPLINE
    # remove duplicates from the list of all dependencies (up to 2nd-order)
    depends_all=$(rm_list_duplicates $deps_all)
    log "* All dependencies of '$1':"
    for dep in $depends_all
    do
        log "+ $dep"
    done
    log $SEPLINE
    # returned value is stored in `depends_all`
    echo $depends_all
}

# rename the external libraries to their library ids
for lib in $xlibdir/*.dylib; do
    lib_id=$(dylib_base_id $lib)
    mv "$lib" "$xlibdir/$lib_id"
done

# gather all dependencies (up to 2nd order)
for lib in $libfiles; do
    _dps="$(get_depends $lib)"
    deps_paths="$deps_paths $_dps"
done
deps_paths=$(rm_list_duplicates $deps_paths)

# gather the Python dependence
for lib in $libfiles; do
    _dps=$(get_python_dependence "$lib")
    _pydep="$_pydep  $_dps"
done
# get the first element the list Python dependences
_pydep=( $_pydep )
pydepends_fullpath=${_pydep[0]}
pydepends_filename=${_pydep[1]}
unset _pydep

log "Python-dependence: '$pydepends_fullpath'"
log "Python library: '$pydepends_filename'"

py_fmwk_rpaths=$(get_python_framework_path "$pydepends_fullpath")

# gather dependencies on BA libraries
for lib in $libfiles; do
    _dps=$(get_BA_depends "$lib")
    ba_deps="$ba_deps  $_dps"
done
ba_deps=$(rm_list_duplicates $ba_deps)

# collect the dependency data into arrays
declare -a depends_fullpath depends_filename

for dep in $deps_paths; do
    fnm=$(basename "$dep") # dependency basename
    # Python-dependence is considered separately
    if [[ $fnm =~ .*Python|libpython.* ]]; then
        continue
    fi
    # ignore dependence on BA libraries
    if [[ $fnm = *BA* ]]; then
        continue
    fi
    echo "$TITLE: Change '$dep' => '$fnm'"
    depends_fullpath+=( $dep )
    depends_filename+=( $fnm )
done

declare -a ba_depends_fullpath ba_depends_filename
# eg. '@rpath/_libBABase.1.2.so' => '_libBABase.so'
ba_lib_re='s;.*(_libBA[[:alpha:]]+).*\.(so|dylib);\1.\2;p'
for dep in $ba_deps; do
    fnm=$(echo "$dep" | sed -nE $ba_lib_re)
    if [ -z $fnm ]; then
        continue
    fi
    echo "$TITLE: Change '$dep' => '$fnm'"
    ba_depends_fullpath+=( $dep )
    ba_depends_filename+=( $fnm )
done

#-- copy external dependencies to the associated folder
for idx in "${!depends_fullpath[@]}"; do
    pth=${depends_fullpath[idx]}
    fnm=${depends_filename[idx]}
    xpth="$xlibdir/$fnm"
    $COPY "$pth" "$xpth"
done
# report the external libraries
xlibfiles="$xlibdir/*.dylib"
echo "$TITLE: External library files in '$xlibdir':"
for lib in $xlibfiles; do
    echo "  - $lib"
done

#-- modify the library references in all files
# ref to external libraries
for filenm in $libfiles $xlibfiles; do
    for idx in "${!depends_fullpath[@]}"; do
        pth=${depends_fullpath[idx]}
        fnm=${depends_filename[idx]}
        # change the dependency path in the library
        # eg. '/usr/local/opt/foo.dylib' => '@rpath/foo.dylib'
        rpth="@rpath/$fnm"
        install_name_tool "$filenm" -change "$pth" "$rpth"
    done
    log "Changed references in '$filenm'"
done

# ref to BA libraries
for filenm in $libfiles; do
    for idx in "${!ba_depends_fullpath[@]}"; do
        pth=${ba_depends_fullpath[idx]}
        fnm=${ba_depends_filename[idx]}
        # change the dependency path in the library
        # eg. '@rpath/_libBABase.1.so' => '@rpath/_libBABase.so'
        rpth="@rpath/$fnm"
        install_name_tool "$filenm" -change "$pth" "$rpth"
    done
    log "Changed references in '$filenm'"
done

# ref to Python library
if [ -z $pydepends_fullpath ] || [ -z $pydepends_filename ]
then
    echo "$TITLE: No Python dependence found."
else
    for filenm in $libfiles; do
        log "$pydepends_fullpath => @rpath/$pydepends_filename"
        install_name_tool "$filenm" -change "$pydepends_fullpath" "@rpath/$pydepends_filename"
    done
    # add proper RPATHs
    for filenm in $libfiles; do
        for rpth in $py_fmwk_rpaths; do
            install_name_tool "$filenm" -add_rpath "$rpth"
        done
    done
    echo "$TITLE: Changed references to the Python shared library."
fi

# add proper RPATHs to external libraries
for filenm in $xlibfiles; do
    install_name_tool "$filenm" -add_rpath "@loader_path"
    echo "$TITLE: Added proper RPATHs to '$filenm'"
done

# add proper RPATHs to BA libraries
# for filenm in $libfiles; do
#     install_name_tool "$filenm" \
#        -add_rpath "@loader_path" \
#        -add_rpath "@loader_path/extra"
#     log "$TITLE: Added proper RPATHs to '$filenm'"
# done

# make the Python wheel
echo "$TITLE: Making the Python wheel..."
pushd "$pyoutdir"
$PYTHON -m build --wheel -n -o "$wheeldir"
popd

#-- final message
echo "$TITLE: Done."
