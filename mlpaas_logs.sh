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

curr_dt=`date +"%d_%B_%Y_%H_%M_%S"`
logsPath=$1/mlpaas_data_$curr_dt
mkdir -p $logsPath
chmod 777 $logsPath

touch >> $logsPath/postgress_df.txt
touch >> $logsPath/cassandra_df.txt
touch >> $logsPath/describe_nodes.txt
touch >> $logsPath/top_nodes.txt
touch >> $logsPath/top_pods.txt
touch >> $logsPath/osd_df.txt
touch >> $logsPath/ceph_stat.txt
kubectl describe nodes 2>&1 | awk '{ print strftime("%m/%d/%y %H:%M:%S"), $0; fflush() }' >> $logsPath/describe_nodes.txt
kubectl top node 2>&1 | awk '{ print strftime("%m/%d/%y %H:%M:%S"), $0; fflush() }' >> $logsPath/top_nodes.txt
kubectl top pods -A 2>&1 | awk '{ print strftime("%m/%d/%y %H:%M:%S"), $0; fflush() }' >> $logsPath/top_pods.txt
kubectl exec -it `kubectl get pod -n openshift-storage | grep "rook-ceph-tools" | awk '{ print $1 }'` -n openshift-storage -- ceph osd df >> $logsPath/osd_df.txt
kubectl exec -it `kubectl get pod -n openshift-storage | grep "rook-ceph-tools" | awk '{ print $1 }'` -n openshift-storage -- ceph -s >> $logsPath/ceph_stat.txt
kubectl exec -it -n sepmlpaas sepmlpaas-chart-postgresql-primary-0 -- df -kh >> $logsPath/postgress_df.txt
kubectl exec -it cassandra-0 -n sepmlpaas -- df -kh >> $logsPath/cassandra_df.txt
kubectl exec -it cassandra-1 -n sepmlpaas -- df -kh >> $logsPath/cassandra_df.txt
kubectl exec -it cassandra-2 -n sepmlpaas -- df -kh >> $logsPath/cassandra_df.txt
kubectl exec -it -n sepmlpaas sepmlpaas-chart-postgresql-primary-0 -- pg_dump -U admin_user -d mlpaas > $logsPath/att_postgres_data_`date +%m-%d-%Y-%H%M`.psql <<< testing123

