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
        exit_error "NO directory PROVIDED, usage $script <source dir> <destination dir>"
        exit 1
fi

statsLogs_path="$1"
CPU_MEM_PATH="$2"
readable=`ls $statsLogs_path | grep -i Logs_ATT`
echo $readable
filename_all=($readable)
for filename in "${filename_all[@]}"
do
        filename1=`echo $filename | awk -F . '{print$1}'`-CPUMEM
        if [ -e $CPU_MEM_PATH/$filename1 ]
        then

            echo "$filename1 already present"
        else
            mkdir -p $CPU_MEM_PATH/$filename1
            tar -C $CPU_MEM_PATH/$filename1 -xvf $statsLogs_path/$filename home/labadmin/Logs_ATT/CPUandMEM
	    mv /$CPU_MEM_PATH/$filename1/home/labadmin/Logs_ATT/CPUandMEM/ /$CPU_MEM_PATH/$filename1/
	    if [ -d "$CPU_MEM_PATH/$filename1/home" ]; then
	    	rm -rf $CPU_MEM_PATH/$filename1/home
	    fi
	    mkdir -p $CPU_MEM_PATH/$filename1/MEMORYperPOD
	    mkdir -p $CPU_MEM_PATH/$filename1/CPUperPOD
	    mkdir -p $CPU_MEM_PATH/$filename1/Graphs
	    pod_dir=$(ls $CPU_MEM_PATH/$filename1/CPUandMEM/TOP_OUTPUT | grep top_output | head -1)
	    echo $pod_dir
	    pod_list=$(cat $CPU_MEM_PATH/$filename1/CPUandMEM/TOP_OUTPUT/$pod_dir | grep -v NAME | awk '{print$2}')
	    pod_list_duringRun=($pod_list)
	    echo -e pod_namespace'\t'pod_name'\t'maxCpu'\t'avgCpu'\t'maxMem'\t'avgMem > $CPU_MEM_PATH/$filename1/pod_cpu_memory_status.csv
            echo -e date'\t'time'\t'node_name'\t'Cpu'\t'percentageCpu'\t'Mem'\t'percentageMem > $CPU_MEM_PATH/$filename1/node_cpu_memory_status.csv
            readable=`ls $CPU_MEM_PATH/$filename1/CPUandMEM/NODE_OUTPUT | awk -F _ '{print$3"_"$4"_"$5"_"$6"_"$7"_"$8}'| sort`
            var_all=($readable)
            for var in "${var_all[@]}"
            do
                file=`ls $CPU_MEM_PATH/$filename1/CPUandMEM/NODE_OUTPUT | grep $var`
                time=`echo $var | awk -F _ '{print$4"_"$5"_"$6}'`
                date=`echo $var | awk -F _ '{print$1"_"$2"_"$3}'`
                sed "s/^/$date\t$time\t/" $CPU_MEM_PATH/$filename1/CPUandMEM/NODE_OUTPUT/$file | grep -v NAME >> $CPU_MEM_PATH/$filename1/node_cpu_memory_status.csv
            done

	    for pod_name in "${pod_list_duringRun[@]}"
	    do
	        numTotal=$(cat $CPU_MEM_PATH/$filename1/CPUandMEM/TOP_OUTPUT/top_output_* | grep $pod_name | awk '{print$3}' | wc -l)
	        podMem=$(cat $CPU_MEM_PATH/$filename1/CPUandMEM/TOP_OUTPUT/top_output_* | grep $pod_name | awk '{print$4}')
	        podCpu=$(cat $CPU_MEM_PATH/$filename1/CPUandMEM/TOP_OUTPUT/top_output_* | grep $pod_name | awk '{print$3}')
	        numMem=($podMem)
	        sum=0
	        maxCpu=0
	        maxMem=0
	        for num in "${numMem[@]}"
	        do
        	        num=${num::-2}
	                sum=$((sum + num))
        	        if [ $num -ge $maxMem ]
	                then
        	            maxMem=$num
	                fi
		done
    	        avgMem=`echo $sum / $numTotal | bc -l`
      	        avgMem=$( printf "%.0f" $avgMem )
    	        numCpu=($podCpu)
	        sum=0
        	for num in "${numCpu[@]}"
	        do
        	        num=${num::-1}
               		sum=$((sum + num))
	                if [ $num -ge $maxCpu ]
        	        then
	                    maxCpu=$num
        	        fi
	        done
	        avgCpu=`echo $sum / $numTotal | bc -l`
	        avgCpu=$( printf "%.0f" $avgCpu )
	        pod_namespace=$(cat $CPU_MEM_PATH/$filename1/CPUandMEM/TOP_OUTPUT/$pod_dir | grep -i $pod_name | awk '{print$1}')
	        echo -e $pod_namespace'\t'$pod_name'\t'$maxCpu'\t'$avgCpu'\t'$maxMem'\t'$avgMem >> $CPU_MEM_PATH/$filename1/pod_cpu_memory_status.csv
		ls $CPU_MEM_PATH/$filename1/CPUandMEM/TOP_OUTPUT/top_output_* | xargs grep -nr $pod_name | awk '{print $2" "$4}' > $CPU_MEM_PATH/$filename1/MEMORYperPOD/memory_$pod_name.csv
		cat $CPU_MEM_PATH/$filename1/MEMORYperPOD/memory_$pod_name.csv | awk '{print$2}' | sed 's/Mi//' | awk '{print NR  " " $s}' > $CPU_MEM_PATH/$filename1/MEMORYperPOD/graph_memory_$pod_name.csv
		ls $CPU_MEM_PATH/$filename1/CPUandMEM/TOP_OUTPUT/top_output_* | xargs grep -nr $pod_name | awk '{print $2" "$3}' > $CPU_MEM_PATH/$filename1/CPUperPOD/cpu_$pod_name.csv
		cat $CPU_MEM_PATH/$filename1/CPUperPOD/cpu_$pod_name.csv | awk '{print$2}' | sed 's/m//' | awk '{print NR  " " $s}' > $CPU_MEM_PATH/$filename1/CPUperPOD/graph_cpu_$pod_name.csv
		/data/plotGraph.sh $CPU_MEM_PATH/$filename1/Graphs/memory_$pod_name.png $CPU_MEM_PATH/$filename1/MEMORYperPOD/graph_memory_$pod_name.csv memory_$pod_name min memory_in_Mi
   	       /data/plotGraph.sh $CPU_MEM_PATH/$filename1/Graphs/cpu_$pod_name.png $CPU_MEM_PATH/$filename1/CPUperPOD/graph_cpu_$pod_name.csv cpu_$pod_name min cpu_in_m
	    done
        fi
	if [ -d "$CPU_MEM_PATH/$filename1/CPUandMEM" ]; then
		rm -rf $CPU_MEM_PATH/$filename1/CPUandMEM
	fi
done

