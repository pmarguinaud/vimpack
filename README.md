![](./Images/45709664.png)


# [vimpack ...](./doc/vimpack.md)

A pack editor based on vim; a vim compiled with the embedded Perl interpreter has to be available in your PATH.
Help is available in vim: type `:help vimpack` from within vimpack.

# [gitpack ...](./doc/gitpack.md)

`gitpack` is a script wrapping `git`. All git commands are available from
within a pack.

# [tarpack ...](./doc/tarpack.md)

Create archives from pack.

# [lstpack ...](./doc/lstpack.md)

List files in local view.

# [fixpack ...](./doc/fixpack.md)

`fixpack` is a script for wrapping gmkpack compiler & linker wrapper scripts. 
It allows the user to debug interactively code at compile time : `gmkpack` 
will invoke it when compiling a FORTRAN unit or linking an executable fails.

# [gdbpack ...](./doc/gdbpack.md)

Run `gdb` on a pack executable.

# [ddtpack ...](./doc/ddtpack.md)

Run `ddt` on a pack executable.

# [dotpack ...](./doc/dotpack.md)

`dotpack` relies on graphviz to create call graphs.

# [bakpack ...](./doc/bakpack.md)

Archive and retrieve packs.

# [davpack ...](./doc/davpack.md)

Run DAVAI test suite from within a pack. 

# [mitpack ...](./doc/mitpack.md)

Run MITRAILLETTE test suite from within a pack.

# [synpack ...](./doc/synpack.md)

When invoked, `synpack` will do the following:

1. Attempt to compile the code in the current pack, if `MASTERODB` is not up-to-date.
2. Commit the last changes with the message passed with the `--message` option.
3. Try to merge the current branch into the pack passed with `--pack1` option.
4. Try to compile `MASTERODB` in the passed with `--pack1` option.

If step 3 or 4 fails, an interactive shell will be created and the user will be expected to :

- If step 3 has failed, finish the merge by hand and commit the last modifications in pack1.
- If step 4 has failed, fix the code and commit the last modifications in pack1.
