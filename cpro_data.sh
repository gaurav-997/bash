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

mkdir -p $1/cpro_data
chmod 777 $1/cpro_data
logsPath=$1/cpro_data
curr_dt=`date +"%d_%B_%Y_%H_%M_%S"`
cpro_svcip=($(kubectl get svc -n ricinfra | grep infra-cpro-server | awk '{print$3}'))
echo $cpro_svcip
cproPodName=($(kubectl get po -n ricinfra | grep cpro-server | awk '{print$1}'))
echo $cproPodName
readable=($(kubectl -n ricplt exec curl-cmd-pod -- curl -XPOST http://$cpro_svcip:80/api/v1/admin/tsdb/snapshot))
echo $readable
snapid=`echo $readable | awk -F : '{print$4}'`
snapid=${snapid::-2}
echo $snapid
kubectl exec -it $cproPodName -n ricinfra -c cpro-util -- bash -c "tar -cvf snap_$curr_dt.tar /data/snapshots/$snapid"
kubectl cp $cproPodName:/cpro-util/snap_$curr_dt.tar $logsPath/snap_$curr_dt.tar -c cpro-util  -n ricinfra
kubectl exec -it $cproPodName -n ricinfra -c cpro-util -- bash -c "rm -rf /cpro-util/snap_$curr_dt.tar"
kubectl exec -it $cproPodName -n ricinfra -c cpro-util -- bash -c "rm -rf /data/snapshots/$snapid"

