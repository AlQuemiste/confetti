#!/bin/zsh

# usage:
# % zsh mk_pypack_macos.sh
#
# This script extracts the library ids of the dynamic libraries (*.dylib)
# found in the library files and accordingly adjusts the library paths
# referring to the external libraries (like `libfftw3.dylib`) in the given libraries.
# The script searches also for dependencies up to the 2nd order and adds
# them to the external libraries.
#
# For instance, the script finds the dynamic libraries (*.dylib)
# in `.../lib/extra` folder, and adjusts the library reference paths
# in each given library file.
#
# Requires MacOS-specific native tools `otool` and `install_name_tool`.
# NOTE: Starting with macOS Catalina (macOS 10), Macs will use `zsh` as
# the default login shell and interactive shell across the operating system.
# All newly created user accounts in macOS Catalina will use zsh by default;
# see <https://support.apple.com/en-us/HT208050>

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
TITLE="MacOS PyPack"
HELP="$TITLE: Usage: zsh mk_pypack_macos.sh"

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

# NOTE: For zsh, splitting on IFS could be done using `echo ${=var}`.

# list of the main library files
libfiles=($libdir/*.so*)

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
function log
{
    if [[ $LOG_FLAG == 1 ]]; then
        echo "$LOG_TOKEN $1" >&2
    fi
}

# use otool to get the base id of a library (raw output)
libname_re='[[:alnum:]_.-]+'
# otool output example:
# ```
# cmd LC_ID_DYLIB
# cmdsize 56
# name @rpath/_libMainAppSample.1.so (offset 24)
# ```
# eg. 'name @rpath/libA.1.so (offset 24)' => 'libA.1.so'
lib_id_re='s;.+name[[:blank:]]+.+/('$libname_re')[[:blank:]]+\(.+;\1;p'

function dylib_base_id
{
    # return the base library id for the given library ($1)
    otool -l "$1" | grep -A2 -F LC_ID_DYLIB | sed -nE $lib_id_re
}

# use otool to get the 1st-order dependencies of a library (raw output)
function dylib_deps
{
    # obtain the dependencies for a given library ($1);
    # remove the first lines which is the name of the file itself
    # otool output example: '  /usr/local/opt/foo.dylib (compatibility ...)'
    otool -L "$1" | tail -n+3
}

function rm_list_duplicates
{
    # remove duplicates from a given list, $@; (separator is a space char)
    echo $@ | tr -s ' ' '\n' | sort -u | tr '\n' ' '
}

# get dependencies of a given library on MainApp libraries
function get_MainApp_depends
{
    # obtain the MainApp dependencies for a given library ($1);
    # remove the first line which is the name of the file itself;
    # find lines containing 'libMainApp'
    dylib_deps "$1" | grep -iF 'libMainApp'
}

# get 1st-order dependencies for a given file
function get_depends1
{
    # obtain the dependencies for a given library ($1)
    local optional_deps_re='/(opt|Cellar)/'
    local _deps=$(dylib_deps "$1" | grep -E $optional_deps_re)
    # make a clean list of dependencies without duplicates
    # eg. '  /usr/local/opt/foo.1.dylib (compatibility ...)' => '/usr/local/opt/foo.dylib'
    # NOTE: References starting with '@' must be neglected;
    # eg., '@rpath/foo.dylib'
    local path_re='s;[[:blank:]]*([^@]'$libname_re')[[:blank:]]+.+;\1;p'
    echo "$_deps" | sort -u | sed -nE $path_re
}

# get Python dependence for a given file
function get_python_dependence
{
    # extract the Python dependency from the given library ($1)
    # regexp to extract the Python dependence; eg.,
    # '/usr/local/opt/python@3.9/Frameworks/Python.framework/Versions/3.9/Python'
    libdir_re='[[:alnum:]_./-]'
    py_fmwk_re='s;[[:blank:]]*([^@]'$libdir_re')/(Python|libpython.+\.dylib)[[:blank:]]+.+;\1/\2;p'
    # regexp to correct the Python dependence; eg.:
    # '/usr/local/opt/python@3.9/Frameworks/Python.framework/Versions/3.9/Python' => 'libpython3.9.dylib'
    # '/usr/local/opt/python@3.9/Frameworks/Python.framework/Versions/3.9/libpython3.9.dylib' => 'libpython3.9.dylib'
    pylib_re='s;.*[pP]ython.+[Vv]ersions/([0-9.]+).+(Python|libpython).*;libpython\1.dylib;'
    # obtain the dependencies
    pydeps0=$(dylib_deps "$1")
    pydepends_fullpath=$(echo "$pydeps0" | sed -nE $py_fmwk_re)
    pydepends_filename=$(echo "$pydepends_fullpath" | sed -E $pylib_re)
    # return the Python dependence fullpath and filename
    echo "$pydepends_fullpath  $pydepends_filename"
}


# get Python dependence for a given file
function get_python_framework_path
{
    local pydepends_fullpath=$1
    # regexp to extract the Python framework path
    # eg. '/usr/local/opt/python@3.9/Frameworks/Python.framework/Versions/3.9/Python'
    #   => '/usr/local/opt/python@3.9/Frameworks/Python.framework/Versions/3.9/'
    py_fmwk_path_re='s;(.*)/(Python|libpython).*;\1;'
    # regexp to extract the Python version; eg. '3.9'
    pyversion_re='s;.*[pP]ython.+[Vv]ersions/([0-9.]+).*;\1;'
    # obtain the dependencies; remove the first line which is
    # the name of the file itself
    pyversion=$(echo "$pydepends_fullpath" | sed -E $pyversion_re)
    py_fmwk_dir=$(echo "$pydepends_fullpath" | sed -E $py_fmwk_path_re)
    # collect RPATHs corresponding to the common framework paths
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
    for pth in `echo ${=framework_paths}`; do
        py_fmwk_rpaths="$py_fmwk_rpaths  $pth/$py_fmwk_path"
    done
    # return a list of possible framework paths
    echo $py_fmwk_rpaths
}


# rename the external libraries to their library ids
for lib in $xlibdir/*.dylib*; do
    lib_id=$(dylib_base_id $lib)
    mv -fn "$lib" "$xlibdir/$lib_id"
done

# gather all dependencies
declare -i LEVELMAX=20 level=0
declare -a libs_lv=($libfiles)
declare -A ex_deps deps_lv
echo "$TITLE: Find optional dependencies (up to level $LEVELMAX)..."

while [[ $libs_lv ]]; do
    level+=1 # level nr.
    deps_lv=() # dependencies at the current level (without duplicates)

    # avoid going infinitely deep (due to some error)
    if (( $level > $LEVELMAX )); then
	    echo "Error: Dependency level $level is too deep."
	    break
    fi
    # eg. at level 3, print '===[3]'
    for i in {1..$level}; do print -n '='; done; print "[$level]"

    # obtain all dependencies at the current level
    for lib in $libs_lv; do
	    echo "[L$level] $lib"
	    deps_=$(get_depends1 $lib)
        # NOTE: Associative array is used to make the entries unique
	    for dp in `echo ${=deps_}`; do
	        deps_lv[$dp]=1
	    done
    done
    # libraries for the next level are the dependencies at the current level
    libs_lv=("${(k)deps_lv[@]}")
    # add the dependencies of the current level to set of all dependencies
    for lib in $libs_lv; do
	    # ignore dependence on Python libraries
	    [[ $lib =~ ".*Python|libpython.*" ]] && continue
	    # ignore dependence on MainApp libraries
	    [[ $lib = "*MainApp*" ]] && continue
	    ex_deps[$lib]="${lib##*/}" # the basename of the library
    done
done
echo "...Done."
echo "$TITLE: All optional dependencies (last level $level) {full-path => basename}:"
for pth fnm in "${(@kv)ex_deps}"; do
    echo " + '$pth' => '$fnm'"
done

# gather dependencies on MainApp libraries
declare -A ba_deps
# eg. '  @rpath/_libMainAppBase.1.so.1.2 (compatibility ...)'
#  => '_libMainAppBase.1.so.1.2'
ba_lib_ref_re='s;[[:blank:]]*(.*/_libMainApp.+\.[0-9.]*so[0-9.]*).+;\1;p'
# eg. '@rpath/_libMainAppBase.1.2.so' => '_libMainAppBase.so'
ba_lib_re='s;.*(_libMainApp[[:alpha:]]+)\..+;\1.so;p'
for lib in $libfiles; do
    deps=$(get_MainApp_depends "$lib" | sed -nE $ba_lib_ref_re)
    for libref in `echo ${=deps}`; do
	    # if already seen, then do nothing
	    [[ -v 'ba_deps[$libref]' ]] && continue
        fnm=$(echo "$libref" | sed -nE $ba_lib_re)
        # if extracted basename is empty, then do nothing
        [[ -z $fnm ]] && continue
        ba_deps[$libref]="@rpath/$fnm"
    done
done

echo "$TITLE: References to MainApp libraries {old ref => new ref}..."
for ref0 ref1 in "${(@kv)ba_deps}"; do
    echo " + '$ref0' => '$ref1'"
done

# gather the Python dependence
for lib in $libfiles; do
    _dps=$(get_python_dependence "$lib")
    _pydep="$_pydep $_dps"
done
# get the first element the list Python dependences (all others must be the same)
# NOTE: zsh array indexing starts at 1 (unless option KSH_ARRAYS is set)
_pydep=(`echo ${=_pydep}`)
pydepends_fullpath=$_pydep[1]
pydepends_filename=$_pydep[2]
declare -a py_fmwk_rpaths=($(get_python_framework_path "$pydepends_fullpath"))

echo "$TITLE: Python dependence"
echo " + path: '$pydepends_fullpath'"
echo " + library: '$pydepends_filename'"
echo " + framework paths:"
for pth in $py_fmwk_rpaths; do
    echo "   - '$pth'"
done

#-- copy external dependencies to the associated folder
echo "$TITLE: Copying external dependencies to '$xlibdir'..."

for pth fnm in ${(@kv)ex_deps}; do
    cp -nf "$pth" "$xlibdir/$fnm"
done

# report the external libraries
declare -a xlibfiles=($xlibdir/*.(dylib|so))
echo "$TITLE: External libraries in '$xlibdir':"
for lib in $xlibfiles; do
    # display only the filename (drop the dirname)
    echo " + "${lib##$xlibdir/}
done

#-- modify the library references in all libraries (main & external)
# ref to external libraries
for lib in $libfiles $xlibfiles; do
    for pth fnm in "${(@kv)ex_deps}"; do
        # change the dependency path in the library
        # eg. '/usr/local/opt/foo.dylib' => '@rpath/foo.dylib'
        rpth="@rpath/$fnm"
        install_name_tool "$lib" -change "$pth" "$rpth"
    done
    log "Changed external-library references in '$lib'"
done
# ref to MainApp libraries
for lib in $libfiles; do
    for ref0 ref1 in "${(@kv)ba_deps}"; do
        # change the dependency path in the library
        # eg. '@rpath/_libMainAppBase.1.so.2' => '@rpath/_libMainAppBase.so'
        install_name_tool "$lib" -change "$ref0" "$ref1"
    done
    log "Changed MainApp-library references in '$lib'"
done
# ref to Python library (only in main libraries)
if [ -z $pydepends_fullpath ] || [ -z $pydepends_filename ]; then
    echo "$TITLE: No Python dependence found."
else
    for lib in $libfiles; do
        install_name_tool "$lib" -change "$pydepends_fullpath" "@rpath/$pydepends_filename"
    done
    # add proper framework RPATHs
    for lib in $libfiles; do
        for rpth in $py_fmwk_rpaths; do
            install_name_tool "$lib" -add_rpath "$rpth"
        done
    done
    echo "$TITLE: Changed references to the Python shared library and added framework RPATHs."
fi

# add proper RPATHs to external libraries
for lib in $xlibfiles; do
    install_name_tool "$lib" -add_rpath "@loader_path"
    echo "$TITLE: Added proper RPATHs to '$lib'"
done

# add proper RPATHs to MainApp libraries (if needed)
# for lib in $libfiles; do
#     install_name_tool "$lib" \
#        -add_rpath "@loader_path" \
#        -add_rpath "@loader_path/extra"
#     log "$TITLE: Added proper RPATHs to '$lib'"
# done

# make the Python wheel
echo "$TITLE: Making the Python wheel..."
pushd "$pyoutdir"
eval $PYTHON -m build --wheel -n -o "$wheeldir"
popd

#-- final message
echo "$TITLE: Done."
