#!/bin/bash

# usage:
# % bash mk_pypack_linux.sh
# Requires `ldd`, `readelf` and `bash` >= 4.0.

# externally given variables
pyoutdir="@PY_OUTPUT_DIR@"
libdir="@PY_LIBRARY_OUTPUT_DIR@"
xlibdir="@PY_EXTRA_LIBRARY_OUTPUT_DIR@"
wheeldir="@PY_PACKAGE_WHEEL_DIR@"
PYTHON="@__Py3_EXECUTABLE@"

# constants
TITLE="Linux PyPack"
HELP="$TITLE: Usage: bash mk_pypack_linux.sh"

# shell commands
COPY="/usr/bin/cp -nf"
MKDIR="/usr/bin/mkdir -p"

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

echo "$TITLE: library directories = '$libdir', '$xlibdir'"

# libraries allowed to be included in the package
libs_inc_re='cerf|formfactor|gsl|fftw|boost|zstd|lzma|bz2|tiff|jpeg|jbig'

# extract dependency names and locations from the raw output of `ldd`
# NOTE: ldd returns all dependencies recursively.
# ldd output example:
# ```
#   libgsl.so.25 => /lib/x86_64-linux-gnu/libgsl.so.25 (0x7f764fd5b)
# ```
libname_re='[[:alnum:]_.-]+'
libpath_re='[[:alnum:]_./-]+'
ldd_re='.*lib('$libs_inc_re')('$libname_re')\s*=>\s*('$libpath_re')\s.*'
KVFS=';' # separator token for key and value
function dependencies
{
    # given a library full path ($1), obtains dependency names and locations
    # from the raw output of `ldd`
    ldd "$1" | sed -nE $deps_kv_re
}

# extract the so-name of a library from the raw output of `readelf`
# readelf output example:
# ```
# 0x0000e (SONAME)   Library soname: [_libFoo.1.2.so]
# ```
soname_re='s/.+SONAME.+soname:\s+\[('$libname_re')\].*/\1/p'
function soname
{
    # given a library full path ($1), obtains the so-name of the library
    # from the raw output of `readelf`
    readelf -d "$1" | sed -nE $soname_re
}

# associated array to hold the dependencies {library so-name => full path}
declare -A deps_all
deps_kv_re='s/'$ldd_re'/lib\1\2'$KVFS'\3/p'
# list of the main library files (MainApp shared libraries)
libs_main="$libdir/*.so"
for lib in $libs_main; do
    deps=$(dependencies $lib)
    for key_val in $deps; do
        # use 'parameter expansion' to extract the key and value
        # strip the given pattern from back of the variable (longest match);
        # eg. `K;V` => `K`
        key="${key_val%%$KVFS*}"
        # strip the given pattern from front of the variable (longest match);
        # eg. `K;V` => `V`
        value="${key_val##*$KVFS}"
        deps_all[$key]="$value"
    done
done

echo "$TITLE: External dependencies:"
for lib in ${!deps_all[@]}; do
    libpath=${deps_all[$lib]}
    echo " + $lib => $libpath"
done

# rename the external libraries to their library ids
for xlib in $xlibdir/*.so*; do
    xlib_soname=$(soname $xlib)
    mv "$xlib" "$xlibdir/$xlib_soname"
done

# copy external libraries to the corresponding directory
echo "$TITLE: Copying external libraries to '$xlibdir'..."
$MKDIR $xlibdir
for xlib in "${!deps_all[@]}"; do
    xlibpath="${deps_all[$xlib]}"
    # NOTE: The final name must be the so-name of the library
    $COPY "$xlibpath" "$xlibdir/$xlib"
done

echo "$TITLE: External libraries in '$xlibdir':"
for lib in $xlibdir/*.so*; do
    echo " + $lib"
done

# make the Python wheel
echo "$TITLE: Making the Python wheel..."
pushd "$pyoutdir"
$PYTHON -m build --wheel -n -o "$wheeldir"
popd

# final message
echo "$TITLE: Done."
