#!/bin/bash

for((i=1;i<=$1;i+=1));
do
  octave --eval \
  "p = opt_struct2('length',${i}); printf('length: %f\n',p.Length); fflush (stdout);pause(1+rand);" &

  if(( ($i % $(nproc)) == 0))
  then 
    wait; 
  fi
done
