# NAME

gitpack

# SYNOPSIS

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

# DESCRIPTION

`gitpack` is a script wrapping `git`. All git commands are available from
within a pack.

`gitpack` will synchronize files between the git repository and the gmkpack
local view : all changes made to the files located in the local view are copied
back to the git repository; in return, all git commands such as checkout, merge, 
etc. will propagate to gmkpack local view.

When synchronizing files to the local view, `gitpack` will take into account
existing files in other `gmkpack` views (main, inter.1, inter.2, etc.)

# INITIALIZING A PACK

In order to use `gitpack`, a pack has to be initialized. Two possibilities :

## The current pack is derived from another pack, which has already beeen initialized with gitpack:

In this case, running the following command is sufficient :

    $ gitpack --init

The derived pack will inherit the branch of its master pack.

## No gitpack initialisation has been performed in the current pack hierarchy:

It is then necessary to initialize the current pack from an existing git repository; 
for instance :

    $ gitpack --init --repository $HOME/IAL

# GITPACK CONFIGURATION

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

# SEE ALSO

`gmkpack`, `git`

# AUTHOR

pmarguinaud@hotmail.com
