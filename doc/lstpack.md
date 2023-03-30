[1mNAME[0m
    lstpack

[1mSYNOPSIS[0m
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

[1mDESCRIPTION[0m
    List files in local view.

[1mSEE ALSO[0m
    "gmkpack"

[1mAUTHORS[0m
    pmarguinaud@hotmail.com

