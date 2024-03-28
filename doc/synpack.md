# NAME

synpack

# SYNOPSIS

    # Modify the code
    [ECA 49t1_test1.03.IMPIIFC2018.x]$ vimpack stepo.F90                                
    # Merge modifications in another pack
    [ECA 49t1_test1.03.IMPIIFC2018.x]$ synpack --pack1 ../49t1_test2.03.IMPIIFC2018.x     

# DESCRIPTION

When invoked, `synpack` will do the following:

1. Attempt to compile the code in the current pack, if `MASTERODB` is not up-to-date.
2. Commit the last changes with the message passed with the `--message` option.
3. Try to merge the current branch into the pack passed with `--pack1` option.
4. Try to compile `MASTERODB` in the passed with `--pack1` option.

If step 3 or 4 fails, an interactive shell will be created and the user will be expected to :

- If step 3 has failed, finish the merge by hand and commit the last modifications in pack1.
- If step 4 has failed, fix the code and commit the last modifications in pack1.

# SEE ALSO

`gmkpack`, `gitpack`, `vimpack`

# AUTHOR

pmarguinaud@hotmail.com
