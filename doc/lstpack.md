# NAME

lstpack

# SYNOPSIS

    $ lstpack 
    M arpifs/adiab/spcsi.F90
    + arpifs/adiab/spcsidg_part1.F90
    + arpifs/adiab/spcsidg_part2.F90
    ...
    + arpifs/module/util_yommp0_mod.F90
    M arpifs/setup/sutrans0.F90
    M arpifs/setup/sutrans.F90
    + ifsaux/hack/yomdbg.F90
    8 modified, 11 new

    $ lstpack -d
    + arpifs/adiab/spcsidg_part1.F90.xml
    M arpifs/adiab/spcsi.F90
    3c3
    <  & YDGEOMETRY,YDCST,YDLDDH,YDRIP,YDDYN,KM,KMLOC,KSTA,KEND,LDONEM,&
    ---
    >  & YDGEOMETRY,YDCST,YDLDDH,YDRIP,YDDYN,KSPEC2V,LDONEM,&
    69c69
    < USE YOMMP0       , ONLY : MYSETV
    ---
    ...

# DESCRIPTION

List files in local view.

# SEE ALSO

`gmkpack`

# AUTHORS

pmarguinaud@hotmail.com
