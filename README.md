![](./Images/gmkpack.jpg)


# vimpack

## NAME

vimpack

## DESCRIPTION

A pack editor based on vim; a vim compiled with the embedded Perl interpreter has to be available in your PATH.
Help is available in vim: type `:help vimpack` from within vimpack.

## SEE ALSO

`gmkpack`, `vim`

## AUTHOR

Philippe.Marguinaud@meteo.fr
    vimpack 
      -d    Open vimdiff (difference with base pack and current pack)
      -i    Create index and exits
      -g    Use GUI vim
      -b    Open a backtrace
      -w    Insert warnings & message from the compiler in the code
      -h    Help
      -x    Dump documentation 
    *vimpack.txt*
    
                         Gmkpack-ready Vim editor 
    
    Gmkpack and Vim                                     *vimpack* 
    
    1. Description                                      |vimpack-description|
    2. Usage                                            |vimpack-usage|
    3. Principles                                       |vimpack-principles|
    4. Commands and mappings                            |vimpack-commands|
    5. History                                          |vimpack-history|
    
    ==============================================================================
    1. Description                                      *vimpack-description*
    
    A pack editor based on vim; a vim compiled with the embedded Perl interpreter 
    has to be available in your PATH. 
    
    ==============================================================================
    2. Usage                                            *vimpack-usage*
    
    You must first cd to a valid pack.  An index must have been build using the 
    `vimpack -i' command. Then just type `vimpack filename.F90'; for instance >
    
     vimpack cnt0.F90
    
    <
    
    To edit in diff mode (assuming cnt0.F90 has been modified in an intermediate 
    or local pack) >
    
     vimpack -d cnt0.F90
    
    <
    
    ==============================================================================
    3. Principles                                       *vimpack-principles*
    
    vimpack looks up files in your pack using the index created by vimpack -i; 
    please run `vimpack -i' before attempting to edit any file with vimpack. 
    If a file already belongs to your local branch, then vimpack will edit it 
    directly. Otherwise (the file you requested belong to the main or an 
    intermediate branch), you will be given a copy of this file to edit (you can
    see that in Vim status bar).
    It is possible to commit temporary edited files using the :C command; writing
    a temporary file (using :w) will automatically commit the file if it has been
    modified.
    
    Text based search is possible and has the following features :
    
    - case insensitive
    - strings and comments are taken into acount
    - keywords are searched too
    
    Search for a word using the following command >
    
     :F wrgp2fa
    
    <
    
    If the cursor is over a word, this word can be looked up using the <TAB> key.
    
    For instance, searching for yomct3 yields the following output >
    
    ald/adiab/especrt.F90
    
        62 | USE YOM_YGFL , ONLY : YGFL, YQ, YL, YI,YR, YS, YG
        63 | USE TRAJECTORY_MOD,ONLY : LTRAJGP, GET_TRAJ_GRID
        64 | USE YOMCT3   , ONLY : NSTEP
        65 | USE YOMLUN   , ONLY : NULOUT
        66 | 
    
    ald/c9xx/ecoptra.F90
    
        48 | 
        49 | USE YOMCT0   , ONLY : NSTART   
        50 | USE YOMCT3   , ONLY : NSTEP
        51 | USE YOMDIM   , ONLY : NFLEVG
        52 | USE YOMSP    , ONLY : SPA1 
    
    ald/coupling/ecoupl1.F90
    
        37 | USE YOMCT0   , ONLY : NCONF
        38 | USE YOMCT2   , ONLY : NSTAR2
        39 | USE YOMCT3   , ONLY : NSTEP
        40 | USE YOMDIM   , ONLY : NFLEVG   ,NGPBLKS
    
    ...
    
    
    <
    
    When viewing a search result, it is possible to jump to a particular location, 
    just move the cursor to a file name or a line number and press <TAB>.
    
    If <S-TAB> is pressed and if the cursor is over a subroutine (resp. module, 
    resp.  defined type) name inside a CALL (resp. USE, resp. type declaration)
    statement, then the subroutine (resp. module, resp. type) definition will be 
    looked for; if this definition is not found, then ordinaey search results
    will be displayed.
    
    ==============================================================================
    4. Commands and mappings                            *vimpack-commands*
    
                                                        *:F*
    :F mpl_send 
    
    Finds all occurrences of mpl_send in the code.
    
                                                        *:C*
    :C 
    
    Commit a temporary file (if modified) to src/local.
    
                                                        *:Cq*
    :Cq 
    
    Commit to src/local (if file was modified) and exit.
    
                                                        *:E*
    :E filename.F90 
    
    Edit filename.F90
    
                                                        *:D*
    :D 
    
    Diff current file with N-1 version.
    
    <TAB> 
    
    Search for word under cursor.
    
    <S-TAB> 
    
    Search for entity definition (when possible).
    
    <BS> 
    
    Go back in the history.
    
    ==============================================================================
    5. History                                          *vimpack-history*
    
    May 2012 : Created by Philippe.Marguinaud@meteo.fr
    
    ==============================================================================
     vim:tw=78:ts=8:ft=help:norl:
    

# gitpack

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

# tarpack


# lstpack


# fixpack

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
