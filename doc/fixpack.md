# NAME

fixpack

# SYNOPSIS

Insert in your gmkfile :

    FRTNAME = /home/gmap/mrpm/marguina/bin/fixpack --type xterm --log -- /home/gmap/mrpm/khatib/public/bin/mpiifort_wrapper

Or in your ics\_masterodb :

    cat > $GMKWRKDIR/.masterodb_load <<end_of_masterodb_load
    /home/gmap/mrpm/marguina/bin/fixpack --type xterm  -- mpiifort -v -fp-stack-check -qopenmp -qopenmp-threadprivate compat -shared-intel -lrt -lstdc++
    end_of_masterodb_load

# DESCRIPTION

`fixpack` is a script for wrapping gmkpack compiler & linker wrapper scripts. 
It allows the user to debug interactively code at compile time : `gmkpack` 
will invoke it when compiling a FORTRAN unit or linking an executable fails.

`fixpack` will then start a interactive session allowing the user to edit
the file being compiled and compile it with different options.

Once the user exits the interactive session, the file (if modified) is copied
back to the user local pack. `fixpack` will attempt to compile the file
again.

## SESSIONS

Two kinds of interactive sessions are available (option `--type`):

- xterm

    `fixpack` will create an xterm running a shell in the directory used by 
    `gmkpack`; this xterm will pop up in the user desktop.

- screen

    `fixpack` will create a screen session, that the user can attach to, using
    `screen -x`.

## ALIASES

`fixpack` provides two aliases :

- e

    Edit the file.

- r

    Compile again.

# OPTIONS

- `--type` 

    screen or xterm

- `--warn`

    If set, will print a message in the user terminal where gmkpack is executing,
    stating that the file being compiled is ready for interactive debug.

- `--log`

    If set, `fixpack` will log information in `/tmp/fixpack.$USER.log`.

# EXITING FIXPACK

On exit, `fixpack` will attempt to run the original command. Unless a
script named `compile.sh` exists; in this case, `fixpack` will run 
this script instead of the original command.

# SEE ALSO

`gmkpack`

# AUTHOR

pmarguinaud@hotmail.com
