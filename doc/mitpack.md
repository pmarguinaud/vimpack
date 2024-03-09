# NAME

mitpack

# SYNOPSIS

    $ cd pack
    $ cd 49t1_tot2nvmassweno.03.IMPIIFC2018.x
    $ mitpack                                    #  Create a new MITRAILLETTE test case and run it
    $ mitpack --reuse                            #  Rerun last test case
    $ mitpack --dryrun                           #  Create last test case, but do not run tasks
    $ mitpack --status                           #  Show a small report on all tasks
    $ mitpack --status --reference /path/to/ref  #  Show a small report on all tasks, compare with a reference
    $ mitpack --cancel                           #  Cancel already submitted tasks

# DESCRIPTION

Run MITRAILLETTE test suite from within a pack.

This script will : 

- Create the MITRAILLETTE test case; create a PRO\_FILE, run mitraille.x, and remove dependencies
between individual tasks.
- Start the MITRAILLETTE test case (all tasks at once).

Once the MITRAILLETTE tasks have ended, mitpack will provide a short report for each
of the tasks.

# OPTIONS

- --dryrun

    Create the test case, but do not start any task.

- --reuse

    Reuse the last test case.

- --version

    Provide MITRAILLETTE test version.

- --status

    Show the status for last test case.

- --cancel

    Cancel tasks (with scancel) for last test case.

- --reference

    Provide a reference for comparison; this may be the path of a MITRAILLETTE test case
    of the path of a pack which will be searched for MITRAILLETTE test cases.

# CONFIGURATION & REQUIREMENTS

You need to install MITRAILLETTE in ~/mitraille. You also need to provide a 
PRO\_FILE.version with the list of test you want to run for the version of tests.

# CAVEATS

All tasks are submitted simultaneously. You may hit a limit on the number of jobs allowed
by the scheduler.

# SEE ALSO

`gmkpack`, `mitraillette`

# AUTHOR

pmarguinaud@hotmail.com
