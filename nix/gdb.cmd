# gdb commands to debug a shared library
# usage: gdb -x "gdb.cmd"

# Normally, GDB will load the shared library symbols automatically (controlled by `set auto-solib-add` command)
sharedlibrary $HOME/Projects/nsxtool/build/swig/_pynsx.so

# specify that the program to be run (but not the symbol table)
exec-file /usr/bin/python3
set env PYTHONPATH = $HOME/nsxtool/build/swig

set breakpoint pending on
# break ExperimentImporter::loadData
break $HOME/Projects/nsxtool/core/experiment/ExperimentImporter.cpp:77

set logging on
set logging file /tmp/dbg.log
set logging redirect on

run $HOME/Projects/nsxtool/test/python/TestExperimentFileIO.py > /tmp/dbgout.log

# We can use 'catch throw' in gdb and call 'backtrace' for every single thrown exception. That allows seeing the backtrace of all exceptions that are thrown, including the last uncaught one:

gdb>

https://stackoverflow.com/a/26695274

set pagination off
catch throw
commands
> backtrace
> continue
> end

run
