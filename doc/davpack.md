# NAME

davpack

# SYNOPSIS

    $ cd pack
    $ cd 49t1_tot2nvmassweno.03.IMPIIFC2018.x
    $ davpack                                   # Create & run new test case
    $ davpack --reuse                           # Rerun last test case
    $ davpack --status                          # See status of last test tasks
    $ davpack --cancel                          # Cancel already submitted tasks

# DESCRIPTION

Run DAVAI test suite from within a pack. 

# DETAILS

This script will :

- Create the DAVAI test case and initialize the CIBOULAI interface.
- Compile the executables required for DAVAI.
- Check for other packs (single precision, bound checking) if enabled in the DAVAI configuration
- Create the required symbolic links so that DAVAI can use the executables
- Start the DAVAI test suite

Once the DAVAI tasks have ended, davpack will provide a short report for each of the tasks.

# OPTIONS

- --dryrun

    Do everything, but do not start DAVAI test suite.

- --reuse

    Reuse last DAVAI test case.

- --status

    Show status of DAVAI tasks.

- --cancel

    Cancel tasks (with scancel) for last test case.

- --version

    Version of DAVAI tests. We try to guess the version from the cycle, but you may have 
    to provide it yourself.

# CONFIGURATION

You need to provide a ~/.davai\_profile. In this file, please provide the shell commands
which will enable DAVAI; for instance, on belenos/taranis : 

    module use ~mary/public/modulefiles 
    module load git/2.27.0
    module load python/3.7.6 
    module load davai

This file will be used by davpack to enable DAVAI environment before issuing DAVAI commands.

# REQUIREMENTS

- davai
- gmkpack
- gitpack

# SEE ALSO

`gmkpack`, `DAVAI`

# AUTHOR

pmarguinaud@hotmail.com
