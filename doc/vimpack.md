# NAME

vimpack

# DESCRIPTION

A pack editor based on vim; a vim compiled with the embedded Perl interpreter has to be available in your PATH.
Help is available in vim: type `:help vimpack` from within vimpack.

# SEE ALSO

`gmkpack`, `vim`

# AUTHOR

Philippe.Marguinaud@meteo.fr

# [Short presentation of vimpack](../doc/vimpack.pdf)

vimpack options :


    vimpack 
      -d    Open vimdiff (difference with base pack and current pack)
      -i    Create index and exits
      -g    Use GUI vim
      -b    Open a backtrace
      -w    Insert warnings & message from the compiler in the code
      -h    Help
      -x    Dump documentation 

vimpack documentation (in vimdoc format):


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
    
