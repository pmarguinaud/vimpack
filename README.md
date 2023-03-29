![](./Images/gmkpack.jpg)


# vimpack

## NAME

vimpack

## DESCRIPTION

A pack editor based on vim; a vim compiled with the embedded Perl interpreter has to be available in your PATH.
Help is available in vim: type `:help vimpack` from within vimpack.

## SEE ALSO

`gmkpack`

## AUTHOR

Philippe.Marguinaud@meteo.fr

# gitpack

## NAME

gitpack

## SYNOPSIS

    $ cd pack
    $ cd 48t3_sidyn-spcm.05.IMPIIFC2018.x
    $ gitpack branch 
    cy48t3_cpg_drv+
    cy48t3_cpg_drv+pgi2211+openacc
    cy48t3_cpg_drv+pgi2211+openacc-link
    cy48t3_cpg_drv-
    master
    merge_CY48T3_and_48R1
    merge_CY48T3_and_48R1-pm1
    $ gitpack checkout ...
    $ ...

## DESCRIPTION

`gitpack` is a script wrapping `git`. All git commands are available from
within a pack.

`gitpack` will synchronize files between the git repository and the gmkpack
local view : all changes made to the files located in the local view are copied
back to the git repository; in return, all git commands such as checkout, merge, 
etc. will propagate to gmkpack local view.

When synchronizing files to the local view, `gitpack` will take into account
existing files in other `gmkpack` views (main, inter.1, inter.2, etc.)

## INITIALIZING A PACK

In order to use `gitpack`, a pack has to be initialized. Two possibilities :

### The current pack is derived from another pack, which has already beeen initialized with gitpack:

In this case, running the following command is sufficient :

    $ gitpack --init

The derived pack will inherit the branch of its master pack.

### No gitpack initialisation has been performed in the current pack hierarchy:

It is then necessary to initialize the current pack from an existing git repository; 
for instance :

    $ gitpack --init --repository $HOME/IAL

## GITPACK CONFIGURATION

It is possible to exclude files from `gitpack` management; before initializing the pack,
add a .gitpack.conf. This file may contain a list of regular expressions :

    {
      ignore => [
                  qr,oops_src/,o,
                  qr,dummies.c,o,
                  qr,dummy/unused/,o,
                  ... 
                ]
    }

All files matching one of these regex will not be managed by `gitpack`.

## SEE ALSO

`gmkpack`, `git`

## AUTHOR

pmarguinaud@hotmail.com

# tarpack


# lstpack


# fixpack

## NAME

fixpack

## SYNOPSIS

Insert in your gmkfile :

    FRTNAME = /home/gmap/mrpm/marguina/bin/fixpack --type xterm --log -- /home/gmap/mrpm/khatib/public/bin/mpiifort_wrapper

Or in your ics\_masterodb :

    cat > $GMKWRKDIR/.masterodb_load <<end_of_masterodb_load
    /home/gmap/mrpm/marguina/bin/fixpack --type xterm  -- mpiifort -v -fp-stack-check -qopenmp -qopenmp-threadprivate compat -shared-intel -lrt -lstdc++
    end_of_masterodb_load

## DESCRIPTION

`fixpack` is a script for wrapping gmkpack compiler & linker wrapper scripts. 
It allows the user to debug interactively code at compile time : `gmkpack` 
will invoke it when compiling a FORTRAN unit or linking an executable fails.

`fixpack` will then start a interactive session allowing the user to edit
the file being compiled and compile it with different options.

Once the user exits the interactive session, the file (if modified) is copied
back to the user local pack. `fixpack` will attempt to compile the file
again.

### SESSIONS

Two kinds of interactive sessions are available (option `--type`):

- xterm

    `fixpack` will create an xterm running a shell in the directory used by 
    `gmkpack`; this xterm will pop up in the user desktop.

- screen

    `fixpack` will create a screen session, that the user can attach to, using
    `screen -x`.

### ALIASES

`fixpack` provides two aliases :

- e

    Edit the file.

- r

    Compile again.

## OPTIONS

- `--type` 

    screen or xterm

- `--warn`

    If set, will print a message in the user terminal where gmkpack is executing,
    stating that the file being compiled is ready for interactive debug.

- `--log`

    If set, `fixpack` will log information in `/tmp/fixpack.$USER.log`.

## EXITING FIXPACK

On exit, `fixpack` will attempt to run the original command. Unless a
script named `compile.sh` exists; in this case, `fixpack` will run 
this script instead of the original command.

## SEE ALSO

`gmkpack`

## AUTHOR

pmarguinaud@hotmail.com
