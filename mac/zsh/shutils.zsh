#!/bin/zsh

# Shell helper functions

# For details of ZSH parameter expansions, consult `man zshexpn` or
# <https://zsh.sourceforge.io/Doc/Release/Expansion.html#Parameter-Expansion-Flags>

# use extended glob (see <https://zsh.sourceforge.io/Doc/Release/Expansion.html>);
# similar to `shopt -s extglob` in Bash.
setopt KSH_GLOB

# turn logging off (0), log to stdout (1)
LOG_FLAG=1
LOG_TOKEN=".:"

function log
# NOTE: `echo ... >&2` is used for logging inside functions
{
    if [[ $LOG_FLAG == 1 ]]; then
        echo "$LOG_TOKEN $@" >&2
    fi
}

function dylib_id
# return the base library id for the given library ($1)
{
    otool -XD "$1"
}


function dylib_deps
# use otool to get the 1st-order dependencies of a library (raw output)
{
    # obtain the dependencies for a given library ($1);
    # remove the first lines which is the name of the binary itself
    # otool output example: '  /usr/local/opt/foo.dylib (compatibility ...)'
    otool -XL "$1" | tail -n+2
}

function rm_list_duplicates
# remove duplicates from a given list, $@; (separator is a space char)
{
    echo $@ | tr -s ' ' '\n' | sort -u | tr '\n' ' '
}

function find_common_root
# find the longest common root of two given absolute paths ($1 and $2)
{
    if [[ "$1" = "$2" ]]; then
	    # if paths are equal, the root is equal to either of them
	    common_root="$1"
    else
	    common_root=""
	    # convert paths to arrays of directories:
        # replace '/' with blank and make an array out of the result;
	    # eg. '/root/lib/opt' => [root, lib, opt]
	    declare -ar dirs1=(${=${1//\// }}) dirs2=(${=${2//\// }})
        # NOTE: zsh array indexing starts at 1 (unless option KSH_ARRAYS is set)
	    for idx in {1..$#dirs1}; do
            # extract the head (topmost) directory name from paths
            # eg. 'root/lib/opt' => 'root'
            head1=$dirs1[$idx]
            head2=$dirs2[$idx]
            # if both paths have the same head, then add head to the common root;
            # otherwise, the longest common root is already obtained
            [[ "$head1" != "$head2" ]] && break
	        # if any of the heads are empty, then root-finding is finished
	        [[ -z $head1 || -z $head2 ]] && break
	        # add the common head to the root
            common_root+="/$head1"
	    done
    fi
    # return the longest common root
    print $common_root
}

function test_find_common_root
{
    path1="/PKG/Foo/Content/Binaries"
    path2="/PKG/Foo/Content/Lib/Libraries"
    echo "path1='$path1'; path2='$path2'; common_root='" \
	     $(find_common_root "$path1" "$path2") \
	     "'; expected '/PKG/Foo/Content'"
}

function find_rpath
# find the proper rpath for given binary pointing to a reference library (needs extended glob)
# usage: find_rpath(bin_abspath, lib_abspath, lib_relpath)
# example:
# ```
# bin_abspath='/root/usr/opt/bin'
# lib_abspath='/root/usr/Frameworks/Qux/lib'
# lib_relpath='Qux/lib'
# echo $(find_rpath $bin_abspath $lib_abspath $lib_relpath)
# ```
# returns `../../Frameworks`
{
    # drop the final '/' chars from all paths
    bin_abspath="${1%%+(/)}"  # target binary for which a rpath is obtained
    lib_abspath="${2%%+(/)}"  # referenced library
    lib_relpath="${3%%+(/)}"  # relative path to the referenced library
    # lib_relpath="${lib_relpath##+(/)}"
    # find the longest common root path
    root_path=$(find_common_root "$bin_abspath" "$lib_abspath")
    root_path="${root_path%%+(/)}"
    # obtain the path from the binary to the root
    # eg. '/root/local/opt' => 'local/opt' => '../..'
    binpth_to_root=$(echo $bin_abspath | \
                         sed -E 's,^'$root_path'(/|$),,;s/[^/]+/../g')
    # obtain the path from root to the referenced library;
    # eg. '/root/local/opt' => 'local/opt'
    # then, drop the relative path of the library from the end
    libpth_from_root=$(echo $lib_abspath | \
                           sed -E 's,^'$root_path'(/|$),,;s,(^|/)'$lib_relpath',,')
    # return the proper relative RPATH to the referenced library
    # eg. '../../Frameworks/Qt'
    if [[ -z "$binpth_to_root" ]]; then
	    libpth_from_bin="$libpth_from_root"
    else
	    libpth_from_bin="$binpth_to_root/$libpth_from_root"
    fi
    print $libpth_from_bin
}


function test_find_rpath
{
    msg="$funcstack[1]"
    root='/usr/root/local'
    bin="$root/opt/bin/"
    lib="$root/Frameworks/Qux/Foo.framework/Versions/5/"
    librel='Foo.framework/Versions/5/'
    rpath_ex='../../Frameworks/Qux'
    rpath=$(find_rpath "$bin" "$lib" "$librel")
    echo "$msg: bin_abspath='$bin', lib_abspath='$lib', lib_relpath='$librel' => " \
         "rpath='$rpath'; expected '$rpath_ex'"

    echo
    lib="$root/lib/"
    librel=''
    rpath_ex='../../lib'
    rpath=$(find_rpath "$bin" "$lib" "$librel")
    echo "$msg: bin_abspath='$bin', lib_abspath='$lib', lib_relpath='$librel' => " \
         "rpath='$rpath'; expected '$rpath_ex'"

    echo
    lib="$bin"
    librel=''
    rpath_ex=''
    rpath=$(find_rpath "$bin" "$lib" "$librel")
    echo "$msg: bin_abspath='$bin', lib_abspath='$lib', lib_relpath='$librel' => " \
         "rpath='$rpath'; expected '$rpath_ex'"

}

function is_in
# check if an element exists in an array
# usage: is_in(element, array)
# example:
# ```
# declare -a xs=("a" "bc" "d")
# echo $(is_in "b" $xs)
# ```
# returns 0
{
    elm=$1
    shift  # drop the first argument; the rest is the array
    arr=$@
    if [[ " $arr " = *" $elm "* ]]; then
        exists=1
    else
        exists=0
    fi
    print $exists
}


function test_is_in
{
    msg="$funcstack[1]"
    xs_="a  b cd d de   efg"
    declare -ar xs=(${=xs_})
    elm='cd'
    echo "$msg: '$elm' is in { $xs }?" $(is_in $elm $xs) "; expected: 1"
    elm='c'
    echo "$msg: '$elm' is in { $xs }?" $(is_in $elm $xs) "; expected: 0"
}

function get_depends1
# get 1st-order dependencies for a given file
{
    # obtain the 'non-system' dependencies for a given library ($1)
    # eg. '  /usr/local/opt/foo.1.dylib (compatibility ...)' => '/usr/local/opt/foo.dylib'
    # system dependencies pattern: /System/, /Library/, /usr/lib/, /usr/local/lib
    path_re='s;[[:blank:]]*([^[:blank:]]+).*;\1;p'
    system_dep_re='\/(usr\/lib|usr\/local\/lib|System|Library)\/'
    dylib_deps "$1" | sed -nE '/'$system_dep_re'/!'$path_re
}

function find_dependencies
# gather all dependencies for the given initial libraries ($@)
# up to a maximum (but arbitrary) level.
{
    declare -ir LEVELMAX=20 # max. allowed level
    log "$TITLE: Find dependencies (up to level $LEVELMAX)..."
    # NOTE: Associative arrays are used to keep a set of entries without repetition
    declare -A all_deps # absolute dependencies
    declare -a libs_lv=(${=@}) # libraries at the current level
    declare -i level=0 # current level nr.

    while [[ $libs_lv ]]; do
	    level+=1
	    declare -A abs_deps_lv=() # _absolute_ dependencies at the current level
	    # avoid going infinitely deep (due to some error)
	    if (( $level > $LEVELMAX )); then
	        log "Error: Dependency level $level exceeds the maximum allowed depth ($LEVELMAX)."
	        break
	    fi
	    # eg. at level 3, print '==>[L3]'
	    log "==>[L$level]"
	    # obtain all dependencies at the current level
	    for lib in $libs_lv; do
	        # neglect previously-observed libraries
	        [ ! -z $all_deps[$lib] ] && continue
	        log "[L$level] $lib"
	        for dep in $(get_depends1 $lib); do
		        # store relative dependencies which begin with '@'
		        # eg. '@rpath/foo.dylib'
		        if [[ $dep = @* ]]; then
		            all_deps[$dep]=1
		            # abs. path to relative dependencies is not known, therefore
		            # they should not be added to the current abs. dependencies
		            continue
		        fi
		        # add dependency to the current abs. dependencies
    		    abs_deps_lv[$dep]=1
	        done
	    done
	    # add libraries of the current level to set of all dependencies;
	    # libraries at the initial level are neglected.
	    if (( $level > 1 )); then
	        for libpath in $libs_lv; do
		        all_deps[$libpath]=1
	        done
	    fi
	    # libraries for next level are the absolute dependencies at current level
	    libs_lv=( ${(@k)abs_deps_lv} )
    done
    # return all discovered dependencies
    print "${(@k)all_deps}"
}

function get_python_dependence
# extract the Python dependency from the given dependencies ($@)
# NOTE: Under OSX, Python's library name is either 'Python', or
#   for Python3.9, 'libpython3.9.dylib'.
{
    # regexp to extract the Python dependence;
    # eg., '/Frameworks/Python.framework/Versions/3.9/Python'
    libdir_re='[[:alnum:]_./@-]+'
    pylibname_re='Python|libpython.+\.dylib'
    py_fmwk_re='s;[[:blank:]]*('$libdir_re')/('$pylibname_re')[[:blank:]]+.*;\1/\2;p'
    # regexp to correct the Python dependence; eg.:
    # '/Frameworks/Python.framework/Versions/3.9/Python' => 'libpython3.9.dylib'
    # '/Frameworks/Python.framework/Versions/3.9/libpython3.9.dylib' => 'libpython3.9.dylib'
    pydylib_re='s;.*[pP]ython.+[Vv]ersions/([0-9.]+).+;libpython\1.dylib;'
    # obtain the dependencies
    pydepends_fullpath=$(echo $@ | sed -nE $py_fmwk_re)
    pydepends_filename=$(echo "$pydepends_fullpath" | sed -E $pydylib_re)
    # return the Python dependence fullpath and filename
    print "$pydepends_fullpath  $pydepends_filename"
}

function get_python_framework_path
# produce proper Python framework paths for a given Python dependency ($1)
{
    pydepends_fullpath=$1
    # regexp to extract the Python framework path
    # eg. '/opt/python@3.9/Frameworks/Python.framework/Versions/3.9/Python'
    #   => '/opt/python@3.9/Frameworks/Python.framework/Versions/3.9/'
    py_fmwk_path_re='s;(.*)/(Python|libpython).*;\1;'
    py_fmwk_dir=$(echo "$1" | sed -E $py_fmwk_path_re)
    # when the library is like '.../Versions/3.9/Python', then
    # add an extra '/lib' to the framework path;
    # this is needed since it refers to the standard location of the
    # Python shared library on OSX, '.../Versions/3.9/lib/libpython39.dylib'.
    if [[ $1 = */Python ]]; then
        py_fmwk_dir="$py_fmwk_dir/lib"
    fi
    # regexp to extract the Python version; eg. '3.9'
    pyversion_re='s;.+[Vv]ersions/([0-9.]+).*;\1;'
    declare -r pyversion=$(echo "$1" | sed -E $pyversion_re)
    # RPATHs corresponding to the common OSX framework paths
    declare -r py_fmwk_basepath="Python.framework/Versions/$pyversion/lib"
    declare -ar framework_paths=( /usr/local/Library/Frameworks
      /Library/Frameworks  /usr/local/Frameworks )
    # collect proper RPATHs for Python framework
    py_fmwk_rpaths="$py_fmwk_dir"
    for pth in $framework_paths; do
        py_fmwk_rpaths+=" $pth/$py_fmwk_basepath"
    done
    # return a list of possible framework paths
    print $py_fmwk_rpaths
}

#========================================

#-- perform tests --
# print "$(test_find_rpath)"
# print "$(test_is_in)"
#========================================
