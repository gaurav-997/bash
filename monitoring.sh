#!/bin/bash

# here we will calculate the CPU load and provide alerts 
load=`top -bn1 | grep -i load | awk '{printf "%.2f%%/t/t/n" , $(NF-2)} | cut -d '%' -f1`
echo $load
if [[ ${load%.*} -gt 1]]
then
    echo " load is very high: ${load} "
else
    echo "load is normal"
fi

# -bn1 means it will print the 1 batch  only ( b = batch , n= number of times o/p)
# printf "%.2f%%/t/t/n" , $(NF-2) :-( number of fields) NF -2 means it will print the 3rd value ( last -2) , start counting form back
# .2f%%/t/t/n :-  .2f means give o/p till last 2 floting digits, t for tab , n for new line 
# cut -d '%' -f1 :- remove the % and give the first field 

