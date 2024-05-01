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

curr_dt=`date +"%d_%B_%Y_%H_%M_%S"`
logsPath=$1/podLogs_$curr_dt
mkdir -p $logsPath
chmod 777 $logsPath
traffic_podname=($(kubectl get po -n ricxapp | grep traffic | awk '{print$1}'))
imlb_podname=($(kubectl get po -n ricxapp | grep imlb | awk '{print$1}'))
iflb_podname=($(kubectl get po -n ricxapp | grep iflb | awk '{print$1}'))
readable=`kubectl get po -n ricplt | grep oamtdist | awk '{print$1}'`
pod_list_duringRun=($readable)
kubectl logs --since=10m $traffic_podname -n ricxapp > $logsPath/$traffic_podname-$curr_dt
kubectl logs --since=10m $imlb_podname -n ricxapp > $logsPath/$imlb_podname-$curr_dt
kubectl logs --since=10m $iflb_podname -n ricxapp > $logsPath/$iflb_podname-$curr_dt
for pod_name in "${pod_list_duringRun[@]}"
do
	kubectl logs --since=10m $pod_name -n ricplt > $logsPath/$pod_name-$curr_dt
done
files_num=`ls -lrt $1 | grep -v total | wc -l`
echo $files_num

old_dir=`cd $1; find -type f -printf '%T+ %p\n' | sort | head -n 1 | awk -F "/" '{print$2}'`
if [ $files_num -ge 144 ]; then
	echo $old_dir
	rm -rf $1/$old_dir
fi

