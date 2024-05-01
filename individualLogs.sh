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
        filename1=`echo $filename | awk -F . '{print$1}'`-individualLogs
        if [ -e $CPU_MEM_PATH/$filename1 ]
        then

            echo "$filename1 already present"
        else
            mkdir -p $CPU_MEM_PATH/$filename1
            tar -C $CPU_MEM_PATH/$filename1 -xvf $statsLogs_path/$filename home/labadmin/Logs_ATT/ts_kpi_reports
            mv /$CPU_MEM_PATH/$filename1/home/labadmin/Logs_ATT/ts_kpi_reports/ /$CPU_MEM_PATH/$filename1/
            if [ -d "$CPU_MEM_PATH/$filename1/home" ]; then
                rm -rf $CPU_MEM_PATH/$filename1/home
            fi
	    cd $CPU_MEM_PATH/$filename1/ts_kpi_reports/ && tar -zcvf ../ts_kpi_reports.tgz .
            tar -C $CPU_MEM_PATH/$filename1 -xvf $statsLogs_path/$filename home/labadmin/Logs_ATT/mlpaas_data
            mv /$CPU_MEM_PATH/$filename1/home/labadmin/Logs_ATT/mlpaas_data/ /$CPU_MEM_PATH/$filename1/
            if [ -d "$CPU_MEM_PATH/$filename1/home" ]; then
                rm -rf $CPU_MEM_PATH/$filename1/home
            fi
	    cd $CPU_MEM_PATH/$filename1/mlpaas_data/ && tar -zcvf ../mlpaas_data.tgz .
            mkdir -p $CPU_MEM_PATH/$filename1
            tar -C $CPU_MEM_PATH/$filename1 -xvf $statsLogs_path/$filename home/labadmin/Logs_ATT/oamtdist*
            mv /$CPU_MEM_PATH/$filename1/home/labadmin/Logs_ATT/oamtdist* /$CPU_MEM_PATH/$filename1/
            if [ -d "$CPU_MEM_PATH/$filename1/home" ]; then
                rm -rf $CPU_MEM_PATH/$filename1/home
            fi
	fi
	if [ -d "$CPU_MEM_PATH/$filename1/ts_kpi_reports" ]; then
	    rm -rf $CPU_MEM_PATH/$filename1/ts_kpi_reports
	fi
	if [ -d "$CPU_MEM_PATH/$filename1/mlpaas_data" ]; then
	    rm -rf $CPU_MEM_PATH/$filename1/mlpaas_data
	fi
done
