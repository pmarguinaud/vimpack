![](./Images/45709664.png)


# [vimpack ...](./doc/vimpack.md)

A pack editor based on vim; a vim compiled with the embedded Perl interpreter has to be available in your PATH.
Help is available in vim: type `:help vimpack` from within vimpack.

# [gitpack ...](./doc/gitpack.md)

`gitpack` is a script wrapping `git`. All git commands are available from
within a pack.

`gitpack` will synchronize files between the git repository and the gmkpack
local view : all changes made to the files located in the local view are copied
back to the git repository; in return, all git commands such as checkout, merge, 
etc. will propagate to gmkpack local view.

When synchronizing files to the local view, `gitpack` will take into account
existing files in other `gmkpack` views (main, inter.1, inter.2, etc.)

# [tarpack ...](./doc/tarpack.md)

Create archives from pack.

# [lstpack ...](./doc/lstpack.md)

List files in local view.

# [fixpack ...](./doc/fixpack.md)

`fixpack` is a script for wrapping gmkpack compiler & linker wrapper scripts. 
It allows the user to debug interactively code at compile time : `gmkpack` 
will invoke it when compiling a FORTRAN unit or linking an executable fails.

# [gdbpack ...](./doc/gdbpack.md)



# [ddtpack ...](./doc/ddtpack.md)



# [dotpack ...](./doc/dotpack.md)

`dotpack` relies on graphviz to create call graphs.

# [bakpack ...](./doc/bakpack.md)

# POD ERRORS

Hey! **The above document had some coding errors, which are explained below:**

- Around line 2:

    &#x3d;cut found outside a pod block.  Skipping to next block.

# [davpack ...](./doc/davpack.md)

Run DAVAI test suite from within a pack. 

This script will :

- Create the DAVAI test case and initialize the CIBOULAI interface.
- Compile the executables required for DAVAI.
- Check for other packs (single precision, bound checking) if enabled in the DAVAI configuration
- Create the required symbolic links so that DAVAI can use the executables
- Start the DAVAI test suite

Once the DAVAI tasks have ended, davpack will provide a short report for each of the tasks.

# [mitpack ...](./doc/mitpack.md)

Run MITRAILLETTE test suite from within a pack.

This script will : 

- Create the MITRAILLETTE test case; create a PRO\_FILE, run mitraille.x, and remove dependencies
between individual tasks.
- Start the MITRAILLETTE test case (all tasks at once).

Once the MITRAILLETTE tasks have ended, mitpack will provide a short report for each
of the tasks.
