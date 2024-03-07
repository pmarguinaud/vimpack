#!/bin/bash

set -e

perl -e ' use Pod::Markdown '

cat -> README.md << EOF
![](./Images/45709664.png)

EOF

for f in vimpack gitpack tarpack lstpack fixpack gdbpack ddtpack dotpack bakpack davpack mitpack
do

  md=doc/$f.md  

  cat ->> README.md << EOF

# [$f ...](./$md)

EOF


  perldoc -o Markdown $f > $md

  if [ "x$f" = "xvimpack" ]
  then

    cat >> $md << EOF

[Short presentation of vimpack](vimpack.pdf)

vimpack options :

EOF
    echo                                  >> $md
    ./vimpack -h | perl -pe 's/^/    /o;' >> $md

    cat >> $md << EOF

[vimpack documentation (in vimdoc format)](vimpack.txt)

EOF

    ./vimpack -x > doc/vimpack.txt

  fi

  if [ "x$f" = "xdotpack" ]
  then
    cat >> $md << EOF

![](../Images/CPG_GP_HYD.svg)

EOF

  fi

done


