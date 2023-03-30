#!/bin/bash

cat -> README.md << EOF
![](./Images/45709664.png)

EOF

for f in vimpack gitpack tarpack lstpack fixpack gdbpack ddtpack
do
  cat ->> README.md << EOF

# $f

EOF
  
  perldoc -o Markdown $f | perl -pe 's/^#/##/o;' >> README.md

  if [ "x$f" = "xvimpack" ]
  then
    cat >> README.md << EOF

vimpack documentation (in vimdoc format):

EOF
    ./vimpack -h | perl -pe 's/^/    /o;' >> README.md
    echo                                  >> README.md
    ./vimpack -x | perl -pe 's/^/    /o;' >> README.md
  fi

done


