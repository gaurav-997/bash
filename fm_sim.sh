#!/bin/bash

script=`pwd`"/""$0"
interupt=0
clean_up()
{
    echo "Press again CRTL + c to Kill"
    echo "Use kill -9 $$"
    [[ $interupt -ge 1 ]] && exit 0
        (( interupt++ ))
}
trap clean_up SIGHUP SIGINT SIGTERM

exit_error()
{
    echo "$1"
    exit 1;
}


for i in {1..50}
do
        helm delete vppfmsim$i
	rm -rf FM_Sim_V3_$i
done
for i in {1..50}
do
        cp -r FM_Sim_V3/ FM_Sim_V3_$i
        cd FM_Sim_V3_$i;sed -i 's/depName: vppfmsim/depName: vppfmsim'$i'/g' values.yaml;cd ..
        cd FM_Sim_V3_$i/templates;sed -i 's/nodePort: 31162/nodePort: '$((31162 + 2*$i -2))'/g' service.yaml;cd ../..
        cd FM_Sim_V3_$i/templates;sed -i 's/nodePort: 31161/nodePort: '$((31161 + 2*$i -2))'/g' service.yaml;cd ../..
        cd FM_Sim_V3_$i;helm install vppfmsim$i .;cd ..
done
