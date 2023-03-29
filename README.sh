#!/bin/bash

cat -> README.md << EOF
![](./Images/gmkpack.jpg)

EOF

for f in vimpack gitpack tarpack lstpack fixpack
do
  cat ->> README.md << EOF

# $f

EOF
  
  perldoc -o Markdown $f | perl -pe 's/^#/##/o;' >> README.md

  if [ "x$f" = "xvimpack" ]
  then
    echo "\`"    >> README.md
    echo         >> README.md
    ./vimpack -h >> README.md
    echo         >> README.md
    ./vimpack -x >> README.md
    echo "\`"    >> README.md
  fi

done


