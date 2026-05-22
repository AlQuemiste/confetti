# GDB
# Resources <https://courses.grainger.illinois.edu/cs225/sp2022/resources/>

To launch the program using gdb, run the following command:
```
gdb [program name]
```

To run the program with optional command line arguments:
```
(gdb) run [arguments]
```

Alternatively, you can do this in one line with the following command:

```
gdb --args ./program_name [optional] [args] [here]
```

This allows you to simply type

```
(gdb) run
```

to start the program.

## Commands within GDB

* `break [file:line number]`. Abbreviation: `b`. eg. `break skipList.cpp:40`
- When the program is stopped (by a previous use of `break`) in a certain file,
  `break n` will create a breakpoint at line `n` in that same file.
- Note: There are other variations on how to use `break` [here](http://www.delorie.com/gnu/docs/gdb/gdb_29.html).
  One variation is breaking at a function belonging to a class. eg. `break SkipList::insert`.

* `clear [file:line number]` removes a breakpoint.

* `run (arguments)` (abbreviation `r`) runs the program, starting from the main function.

* `list` shows the next few lines where the program is stopped.

* `layout src` shows an updating window with the source code and the current line of execution.
  Usually easier than type `list` every line or referring back to the open code.

* `next` (abbreviation `n`) continues to the next line executed. This does not enter any functions. See `step` for this.

* `step` (abbreviation `s`) continues to the next line executed. Unlike `next`, this will *step* into any proceeding functions.

* `finish` (abbreviation `fin`) steps out of a function.

* `continue` (abbreviation `c`) continues the execution of the program after it's already started to run.
  `continue` is usually used after you hit a breakpoint.

# Viewing the state of the code
* `info args` shows the current arguments to the function.
- When stopped within a class's function, the `this` variable will appear.
- `info locals` shows the local variables in the current function.
- `print [variable]` (abbreviation `p`) prints the value of a variable or expression; eg. `print foo(5)`.
  The functionality of `print` is usually superseded by `info locals` if you are looking to print local variables.
  But if you want to view object member variables, `print` is the way to go.
  eg. `print list->head` or `print *integer_ptr`.

* `display [variable]` displays the value of a variable or expression in every iteratation through the code.
   Unlike `print`, `display` is persistent. eg. `display foo(5)`, `display list->head`, or `display *integer_ptr`.

* `backtrace` <ftp://ftp.gnu.org/old-gnu/Manuals/gdb/html_node/gdb_42.html>
Shows the call stack of the program, the list of which function has called the current function, recursively.

* `frame [n]` <https://sourceware.org/gdb/onlinedocs/gdb/Frames.html>
  Used to go to the frame numbers as seen in backtrace.

* [ctrl-o] switches between `layout` window and gdb prompt.

* One would prefer installing `lldb` over using the pretty printer for `gdb`.

* The following instructions will help to be able to print C++ STL structures like vectors nicely in `gdb`.
1. Make a directory for `gdb` pretty printers with the command `mkdir -p ~/gdb_printers/python`.
2. Clone the pretty printer source code:
   `git clone https://github.com/koutheir/libcxx-pretty-printers ~/libcxx-pretty-printers`
3. Move the pretty printer folder inside the repo into the
   `~/gdb_printers/python` directory using `mv ~/libcxx-pretty-printers/src/libcxx ~/gdb_printers/python`
4. Remove the `~/libcxx-pretty-printers` directory: `rm -rf ~/libcxx-pretty-printers`.
5. Setup the `~/.gdbinit` file to load the `gdb` pretty printer.
   - If there exists no `~/.gdbinit` file, run the following command:
     ```
     echo "python\nimport sys\nsys.path.insert(0, '$HOME/gdb_printers/python')\nfrom libcxx.v1.printers import register_libcxx_printers\nregister_libcxx_printers (None)\nend\n" > ~/.gdbinit
     ```
   - If there are already pretty printers setup in the `~/.gdbinit`, add the following lines before the end statement:
     ```
     from libcxx.v1.printers import register_libcxx_printers
     register_libcxx_printers (None)
     ```
