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
        exit_error "NO directory PROVIDED, usage script <source dir> <destination dir>"
        exit 1
fi

statsLogs_path="$1"
CPU_MEM_PATH="$2"
readable=`ls $statsLogs_path | grep -i Logs_ATT`
echo $readable
filename_all=($readable)
for filename in "${filename_all[@]}"
do
        filename1=`echo $filename | awk -F . '{print$1}'`-symtomReport
        if [ -e $CPU_MEM_PATH/$filename1 ]
        then

            echo "$filename1 already present"
        else
            mkdir -p $CPU_MEM_PATH/$filename1
            tar -C $CPU_MEM_PATH/$filename1 -xvf $statsLogs_path/$filename home/labadmin/Logs_ATT/symtomReport
	    mv /$CPU_MEM_PATH/$filename1/home/labadmin/Logs_ATT/symtomReport/* /$CPU_MEM_PATH/$filename1/
	    if [ -d "$CPU_MEM_PATH/$filename1/home" ]; then
	    	rm -rf $CPU_MEM_PATH/$filename1/home
	    fi
	    for symtom in `ls /$CPU_MEM_PATH/$filename1/*.zip`
      	    do
	    	    unzip $symtom '*kubeapidata.zip' -d /$CPU_MEM_PATH/$filename1
		    unzip $CPU_MEM_PATH/$filename1/symptomreport/kubelogs/kubeapidata.zip '*pod-list.json' -d $CPU_MEM_PATH/$filename1/
		    date=`echo $symtom | awk -F _ '{print$8}'`
		    time=`echo $symtom | awk -F _ '{print$9}' | awk -F . '{print$1}'`
		    cat $CPU_MEM_PATH/$filename1/ricinfra/pod-list/pod-list.json | grep -v + | awk -F \| -v date="date" -v time="time" '{print date"\t"time"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9}' | grep NAME > $CPU_MEM_PATH/$filename1/pod_list_$date-$time.csv 
		    cat $CPU_MEM_PATH/$filename1/ricinfra/pod-list/pod-list.json | grep -v + | awk -F \| -v date=$date -v time=$time '{print date"\t"time"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9}' | grep -v NAME >> $CPU_MEM_PATH/$filename1/pod_list_$date-$time.csv 
		    cat $CPU_MEM_PATH/$filename1/ricplt/pod-list/pod-list.json | grep -v + | awk -F \| -v date=$date -v time=$time '{print date"\t"time"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9}' | grep -v NAME >> $CPU_MEM_PATH/$filename1/pod_list_$date-$time.csv 
		    cat $CPU_MEM_PATH/$filename1/ricxapp/pod-list/pod-list.json | grep -v + | awk -F \| -v date=$date -v time=$time '{print date"\t"time"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9}' | grep -v NAME >> $CPU_MEM_PATH/$filename1/pod_list_$date-$time.csv 
		    cat $CPU_MEM_PATH/$filename1/sepmlpaas/pod-list/pod-list.json | grep -v + | awk -F \| -v date=$date -v time=$time '{print date"\t"time"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9}' | grep -v NAME >> $CPU_MEM_PATH/$filename1/pod_list_$date-$time.csv 
		    cat $CPU_MEM_PATH/$filename1/sep-dashboard/pod-list/pod-list.json | grep -v + | awk -F \| -v date=$date -v time=$time '{print date"\t"time"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9}' | grep -v NAME >> $CPU_MEM_PATH/$filename1/pod_list_$date-$time.csv 
		    if [ -d "$CPU_MEM_PATH/$filename1/symptomreport" ]; then
	       	         rm -rf $CPU_MEM_PATH/$filename1/symptomreport
	            fi
		    if [ -d "$CPU_MEM_PATH/$filename1/ricinfra" ]; then
	                rm -rf $CPU_MEM_PATH/$filename1/ricinfra
  	            fi
		    if [ -d "$CPU_MEM_PATH/$filename1/ricplt" ]; then
	                rm -rf $CPU_MEM_PATH/$filename1/ricplt
	            fi
	 	    if [ -d "$CPU_MEM_PATH/$filename1/sep-dashboard" ]; then
	                rm -rf $CPU_MEM_PATH/$filename1/sep-dashboard
	            fi
		    if [ -d "$CPU_MEM_PATH/$filename1/ricxapp" ]; then
	                rm -rf $CPU_MEM_PATH/$filename1/ricxapp
	            fi
		    if [ -d "$CPU_MEM_PATH/$filename1/sepmlpaas" ]; then
	                rm -rf $CPU_MEM_PATH/$filename1/sepmlpaas
	            fi
		    if [ -d "$CPU_MEM_PATH/$filename1" ]; then
	                rm -rf $symtom
	            fi
            done
	fi
done
