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
    cat >> README.md << EOF

vimpack documentation (in vimdoc format):

EOF
    ./vimpack -h | perl -pe 's/^/    /o;' >> README.md
    ./vimpack -x | perl -pe 's/^/    /o;' >> README.md
  fi

done


