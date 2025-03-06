#!/bin/bash
set -e

# preparation of the bash environment
export CHECK_FLAGS=""
export CC=gcc; export CXX=g++
export MPLBACKEND=Agg
eval "$(pyenv init -)"

# info
echo "+++ Build tools +++"
$CXX --version
ldd --version
echo "+++ CMake +++"
cmake --version
echo "+++ Python environment +++"
eval "$(pyenv init -)"
pyenv --version
pyenv root
python --version
echo "++++++++++"  
# execute the main command passed to the container
exec "$@"
