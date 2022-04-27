#!/bin/zsh

# Adjust MacOS Bundle:
# This script is called by CPack to adjust the bundle contents before making
# the final DMG file.
# See also:
# - 'Qt for macOS - Deployment' <https://doc.qt.io/qt-5/macos-deployment.html>
# - 'Using qt.conf' <https://doc.qt.io/qt-5/qt-conf.html>

# Package structure:
# <Package-root>
#  |
#  +--MacOS  {includes main executable: `MainApp`}
#  |
#  +--lib  {main libraries, like `_libMainAppFoo.so`}
#  |
#  +--bin  {not used}
#  |
#  +--Library  {extra libraries, like `libqux`}
#  |
#  +--Frameworks  {Qt framework}
#  |
#  +--PlugIns  {Qt plugins)
#  |
#  +--Resources  {icons and `qt.conf`}
#  |
#  +--share
#     |
#     +--MainApp-<version>
#        |
#        +--Examples
#        |
#        +--Images

# use extended glob (see <https://zsh.sourceforge.io/Doc/Release/Expansion.html>);
# similar to `shopt -s extglob` in Bash.
setopt KSH_GLOB
# allow empty or failing globs
setopt +o nomatch
setopt nullglob

# include shell helper functions
# (expected to be in the same folder as the current script)
scriptdir="$(dirname $0)"
source "$scriptdir"/shutils.zsh
#========================================
declare -r TITLE="* MacOS Package"

#-- directories for the package binaries
pkg_root="$1/Contents" # root dir, eg. '/tmp/MainApp.app/Contents'
main_exe="$pkg_root/MacOS/@MACPK_MAIN_EXE@"
extra_libs="@MACPK_EXTRA_LIBS@"
# eg. input Qt dir = '/usr/local/opt/qt@5/lib/cmake/Qt'
#   => '/usr/local/opt/qt@5'
qtdir="@MACPK_QTDIR@"
qt_framework_root="${qtdir%/lib/*}"
# list of required Qt plugins
qt_plugins="@MACPK_QT_PLUGINS@"
declare -ar qt_plugins=( ${=qt_plugins} )

if [[ -z "$pkg_root" ]]
then
    echo "$TITLE: Error: Provide the root directory of the package."
    exit 1
fi

if [[ -z "$qt_framework_root" ]]
then
    echo "$TITLE: Error: Provide the root directory of the Qt framework."
    exit 1
fi

echo "$TITLE: package root = '$pkg_root'"
echo "$TITLE: main executable = '$main_exe'"
echo "$TITLE: Qt framework root = '$qt_framework_root'"

#-- directories (relative to root) which define the package structure
fwdir="Frameworks"
declare -A pkgbindir=(
    "lib"    "lib"  # main library dir
    "exlib"  "Library"  # external libraries dir
    "FW"     "$fwdir"   # frameworks dir
    "FW_qt"  "$fwdir"  # Qt framework dir
    "FW_qt_plug"  "@MACPK_QT_PLUGINS_DIR@"  # Qt plugins dir
)

#-- copy extra libraries to the Framework-libraries dir;
# the name of the libraries must be the same as the library ids.
if [[ ! -z "$extra_libs" ]]; then
    dst="$pkg_root/$pkgbindir[exlib]"
    echo "$TITLE: Copy extra libraries to '$dst':"
    mkdir -p "$dst"
    for lib in ${=extra_libs}; do
        # eg. 'usr/local/opt/libA.9.dylib' -> '<Package>/Framworks/lib/libA.9.dylib'
        fnm=$(dylib_id "$lib")
        cp -fv "$lib" "$dst/${fnm##*/}"
    done
    unset dst
fi

#-- collect a list of binaries which are already placed in the package
declare -a libs_init=(
    "$main_exe"
    "$pkg_root/$pkgbindir[lib]"/*.(so|dylib)
    "$pkg_root/$pkgbindir[exlib]"/*.(so|dylib)
)

# add the required Qt plugins
echo "$TITLE: Copy required Qt plugins from '$qt_framework_root':"
pkg_plugins_dir="$pkg_root/$pkgbindir[FW_qt_plug]"
for plg in $qt_plugins; do
    # full path of the plugin;
    # eg. '/opt/qt@5/plugins/platforms/libqcocoa.dylib'
    plgpth0="$qt_framework_root/$plg"
    # copy the plugin to the same directory under the _package_ plugins dir;
    # eg. '<Package>/PlugIns/platforms/libqcocoa.dylib'
    pth="$pkg_plugins_dir/${plg#*/}"
    mkdir -p "${pth%/*}"
    cp -fv "$plgpth0" "$pth"
    # add Qt plugin to the list of initial binaries
    libs_init+=( "$pth" )
done
declare -r libs_init

echo "$TITLE: Initially installed binaries under '$pkg_root':"
for fnm in $libs_init; do
    # eg., '+ lib/libA.dylib'
    echo "  + '${fnm#$pkg_root/}'"
done

#-- find the dependencies of the binaries
declare -ar refs_all=( $(find_dependencies $libs_init) )

echo "$TITLE: All dependencies:"
# a sorted list of dependencies
for lib in ${(o)refs_all}; do
    echo "  + '$lib'"
done

#-- distinguish absolute and relative references within dependencies
declare -a abs_refs rel_refs py_refs fw_refs
for ref in $refs_all; do
    if [[ $ref = @* ]]; then
	    # relative reference; eg. '@rpath/foo.dylib'
        rel_refs+=( "$ref" )
    elif [[ $ref = *[Pp]ython* ]] && [[ ! $ref = *boost* ]]; then
        # Python dependencies must be considered separately (exclude 'libboost_python')
        # eg. '/opt/py@3.9/Frameworks/Python.framework/Versions/3.9/Python'
        py_refs+=( "$ref" )
    elif [[ $ref = *\.[Ff]ramework/* ]]; then
        # frameworks must be considered separately
        # eg. '/opt/qt@5/lib/QtGui.framework/Versions/5/QtGui'
        fw_refs+=( "$ref" )
    else
        # absolute reference; eg. '/usr/opt/libA.so'
        abs_refs+=( "$ref" )
    fi
done

#-- copy all absolute dependencies to the package
dst="$pkg_root/$pkgbindir[exlib]"
mkdir -p "$dst"
echo "$TITLE: Copy external libraries to '$dst':"
declare -A pkglib
for ref in $abs_refs; do
    pth="$dst/${ref##*/}"  # destination full-path
    pkglib[$ref]="$pth"
    cp -fv "$ref" "$pth"
done
unset dst

#-- copy all framework dependencies to the package
# Qt framework
qt_fwdir="$pkg_root/$pkgbindir[FW_qt]"
echo "$TITLE: Copy Qt-framework libraries to '$qt_fwdir':"
# extract framework path:
# eg. '/usr/local/opt/qt@5/lib/QtWidgets.framework/Versions/5/QtWidgets (...)'
#   => 'QtWidgets.framework/Versions/5/QtWidgets'
framework_re='s;.+/([^/]+\.[Ff]ramework/[^[:blank:]]+).*;\1;'
for ref in $fw_refs; do
    # only Qt framework is considered
    if [[ ${ref##*/} = Qt* ]]; then
	    # eg., copy '/opt/qt@5/lib/QtGui.framework/Versions/5/QtGui'
	    # to '<Frameworks>/Qt/QtGui.framework/Versions/5/QtGui'
        qtfwdir0=$(echo $ref | sed -E $framework_re)
	    pth="$qt_fwdir/$qtfwdir0"
	    mkdir -p "${pth%/*}"
        pkglib[$ref]="$pth"
        cp -fnv "$ref" "$pth"
    else
        echo "Framework '$ref' neglected." >&2
    fi
done

#-- collect all package binaries for later process
declare -ar pkgbins=( $(rm_list_duplicates ${(v)pkglib} $libs_init "$main_exe") )

echo "$TITLE: All binaries:"
for lib in ${(o)pkgbins}; do
    echo "  + '${lib#$pkg_root/}'"
done

#-- adjust references to libraries
echo "$TITLE: Adjust references to libraries:"
libdir="$pkg_root/$pkgbindir[lib]"
declare -A rpaths bin_deps
for bin in $pkgbins; do
    declare -A rpaths_tmp=()
    bin_deps[$bin]=$(dylib_deps "$bin")
	bindir="${bin%/*}"  # abs. dir of target binary
    # abspth0 = original abs. full-path of the library
    # abspth_pkg = abs. full-path of the library in the package
    for abspth0 abspth_pkg in ${(kv)pkglib}; do
        # if the binary does not depend on the current library, do nothing
        [[ "$bin_deps[$bin]" != *"$abspth0"* ]] && continue
	    # change the library reference in the binary
	    # eg. '/usr/local/opt/lib/libA.5.dylib' => '@rpath/libA.5.dylib'
	    libname="${abspth_pkg##*/}"  # library filename
	    libdir="${abspth_pkg%/*}" # abs. dir of the referenced library
	    librelpth=""  # rel. path of the library
        # make a framework-relative path for the Qt framework libraries
        # eg. '/opt/qt@5/lib/QtGui.framework/Versions/5/QtGui'
        #  => 'QtGui.framework/Versions/5'
	    if [[ $libname == Qt* ]]; then
            # rm framework root dir from the beginning;
            # eg. '/opt/qt@5/lib/QtGui.framework/Versions/5/QtGui'
            #  => 'QtGui.framework/Versions/5/QtGui'
	        librelpth="${abspth_pkg#$qt_fwdir/}"
            # rm filename from the end
            # eg. 'QtGui.framework/Versions/5/QtGui'
            #  => 'QtGui.framework/Versions/5'
	        librelpth="${librelpth%/*}"
	    fi
	    ref_new="$libname"
	    # prepend with library rel. path, if any
	    [[ ! -z $librelpth ]] && ref_new="$librelpth/$ref_new"
        install_name_tool "$bin" -change "$abspth0" "@rpath/$ref_new"
	    # make a proper RPATH to refer to the library within the package
	    # eg. '@loader_path/../Frameworks/Qt/'
	    rpath="@loader_path/"$(find_rpath "$bindir" "$libdir" "$librelpth")
        rpaths_tmp[$rpath]=1
    done
    # store a duplicateless list of rpaths needed for the binary,
    # only if some rpaths are set.
    # NOTE: libraries under the package lib dir. often need
    #   an extra RPATHs '../Library'.
    if [[ $bin == $libdir/* ]]; then
        rpaths_tmp[@loader_path/../$pkgbindir[exlib]]=1
    fi
    rpath_set="${(k)rpaths_tmp}"
    if [[ ! -z "$rpath_set" ]] && rpaths[$bin]="$rpath_set"
done

# find the Python dependence for the *main* libraries
libs_main=( $pkg_root/$pkgbindir[lib]/*.(dylib|so) )
declare -a libs_pydep  # list of Python-dependent libraries
for lib in $libs_main; do
    # get the first element the list Python dependences (all others must be the same)
    _pydep=$(get_python_dependence "$bin_deps[$lib]")
    # record the list of Python-dependent libraries
    [[ ! -z ${_pydep//[[:blank:]]/} ]] && libs_pydep+=( "$lib" )
done
declare -r libs_pydep
# NOTE: zsh array indexing starts at 1 (unless option KSH_ARRAYS is set)
_pydep=( ${=_pydep} )
pydepends_fullpath=$_pydep[1]
pydepends_filename=$_pydep[2]
unset _pydep
declare -ar py_fmwk_rpaths=( $(get_python_framework_path "$pydepends_fullpath") )

for lib in $libs_pydep; do
    rpaths[$lib]+=" $py_fmwk_rpaths[@]"
done

echo "$TITLE: Python dependence for the main libraries in '$pkg_root/$pkgbindir[lib]':"
echo " + path: '$pydepends_fullpath'"
echo " + library: '$pydepends_filename'"
echo " + framework paths:"
for pth in $py_fmwk_rpaths; do
    echo "   - '$pth'"
done

echo "$TITLE: Add proper RPATHs to the binaries:"
for bin in $pkgbins; do
    rpaths_bin="${=rpaths[$bin]}"
    # eg. RPATHS for 'lib/libA.dylib': ../Library , ../Frameworks/Qt
    echo "  + '${bin#$pkg_root/}' => ${rpaths_bin//+([[:blank:]])/ , }"
    if [[ ! -z $rpaths_bin ]]; then
        # eg. install_name_tool libA.so -add_rpath RPATH1 -add_rpath RPATH2 ...
        eval install_name_tool $bin -add_rpath ${rpaths_bin// / -add_rpath }
    fi
done

echo "$TITLE: Done."
