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
if [ $# -eq 0 ]; then
        exit_error "NO LOGS PATH PROVIDED, usage cd $script <logs path>"
        exit 1
fi

if [ ! -d "$1" ]; then
	echo "$1 does not exist."
	exit_error "directory not present"
	exit 1
fi

logsPath=$1/ts_kpi_reports/

nodeName=($(kubectl get po -A -o wide | grep ts-kpi-storage | awk '{print$8}'))
echo $nodeName
sudo scp -r -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null core@$nodeName:/home/ts-kpi-storage $logsPath
curr_dt=`date +"%d_%B_%Y_%H_%M_%S"`
mv $logsPath/ts-kpi-storage $logsPath/ts-kpi-storage-$curr_dt

