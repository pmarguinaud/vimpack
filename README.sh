#!/bin/bash

cat -> README.md << EOF
![](./Images/45709664.png)

EOF

for f in vimpack gitpack tarpack lstpack fixpack gdbpack ddtpack dotpack
do

  md=doc/$f.md  

  cat ->> README.md << EOF

# [$f ...](./$md)

EOF


  perldoc -o Markdown $f > $md

  if [ "x$f" = "xvimpack" ]
  then

    cat >> $md << EOF

# [Short presentation of vimpack](../doc/vimpack.pdf)

vimpack options :

EOF
    echo                                  >> $md
    ./vimpack -h | perl -pe 's/^/    /o;' >> $md

    cat >> $md << EOF

vimpack documentation (in vimdoc format):

EOF
    echo                                  >> $md
    ./vimpack -x | perl -pe 's/^/    /o;' >> $md
  fi

  if [ "x$f" = "xdotpack" ]
  then
    cat >> $md << EOF

![](../Images/CPG_GP_HYD.svg)

EOF

  fi

done


