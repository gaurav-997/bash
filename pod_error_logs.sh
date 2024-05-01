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
logsPath=$1
filename=`cd $1; find -type f -printf '%T+ %p\n' |egrep -v "cronstatus|fileStructure|bkup.tar" | sort | tail -n 1 | awk -F "/" '{print$2}'`
filename1=`echo $filename | awk -F . '{print$1}'`-errorLogs
echo "$filename1"
filename2=`echo $filename | awk -F . '{print$1}'`-individualLogs
dstlogsPath=$2/$filename2
mkdir -p $dstlogsPath/$filename1
tar -C $dstlogsPath/$filename1 -xvf $logsPath/$filename home/labadmin/Logs_ATT/symtomReport
readable=`ls $dstlogsPath/$filename1/home/labadmin/Logs_ATT/symtomReport | grep .zip | grep -v tmp`
echo $readable
filename_all=($readable)
for filename in "${filename_all[@]}"
do
	echo $filename
	symthomdir=`echo $filename | awk -F . '{print$1}'`-errorLog
	mkdir -p $dstlogsPath/$filename1/$symthomdir
	mkdir -p $dstlogsPath/$filename1/$symthomdir/current
	mkdir -p $dstlogsPath/$filename1/$symthomdir/previous
	mkdir -p $dstlogsPath/$filename1/$symthomdir/current/error
	mkdir -p $dstlogsPath/$filename1/$symthomdir/previous/error
	cp $dstlogsPath/$filename1/home/labadmin/Logs_ATT/symtomReport/$filename $dstlogsPath/$filename1/$symthomdir
	unzip -o $dstlogsPath/$filename1/$symthomdir/$filename -d $dstlogsPath/$filename1/$symthomdir
        unzip -o $dstlogsPath/$filename1/$symthomdir/symptomreport/kubelogs/kubeapidata.zip -d $dstlogsPath/$filename1/$symthomdir
	rm -rf $dstlogsPath/$filename1/$symthomdir/$filename
	cp $dstlogsPath/$filename1/$symthomdir/ricplt/logs/current/* $dstlogsPath/$filename1/$symthomdir/current
	cp $dstlogsPath/$filename1/$symthomdir/ricxapp/logs/current/* $dstlogsPath/$filename1/$symthomdir/current
	cp $dstlogsPath/$filename1/$symthomdir/ricinfra/logs/current/* $dstlogsPath/$filename1/$symthomdir/current
	cp $dstlogsPath/$filename1/$symthomdir/sepmlpaas/logs/current/* $dstlogsPath/$filename1/$symthomdir/current
	cp $dstlogsPath/$filename1/$symthomdir/ricplt/logs/previous/* $dstlogsPath/$filename1/$symthomdir/previous
	cp $dstlogsPath/$filename1/$symthomdir/ricxapp/logs/previous/* $dstlogsPath/$filename1/$symthomdir/previous
	cp $dstlogsPath/$filename1/$symthomdir/ricinfra/logs/previous/* $dstlogsPath/$filename1/$symthomdir/previous
	cp $dstlogsPath/$filename1/$symthomdir/sepmlpaas/logs/previous/* $dstlogsPath/$filename1/$symthomdir/previous
	for remDir in `ls $dstlogsPath/$filename1/$symthomdir | egrep -v "current|previous"`
	do
		rm -rf $dstlogsPath/$filename1/$symthomdir/$remDir
	done
	for remFile in `ls -lrt $dstlogsPath/$filename1/$symthomdir/current/ | grep " 0 " | awk '{print$9}'`
	do
		rm -rf $dstlogsPath/$filename1/$symthomdir/current/$remFile
	done
	for remFile in `ls -lrt $dstlogsPath/$filename1/$symthomdir/previous/ | grep " 0 " | awk '{print$9}'`
	do
		rm -rf $dstlogsPath/$filename1/$symthomdir/previous/$remFile
	done
	for remFile in `ls -lrt $dstlogsPath/$filename1/$symthomdir/current/ | awk '{print$9}'`
	do
		newFile=`echo $remFile`-error
		grep -inr error $dstlogsPath/$filename1/$symthomdir/current/$remFile > $dstlogsPath/$filename1/$symthomdir/current/error/$newFile
	done
	for remFile in `ls -lrt $dstlogsPath/$filename1/$symthomdir/previous/ |  awk '{print$9}'`
	do
		newFile=`echo $remFile`-error
		grep -inr error $dstlogsPath/$filename1/$symthomdir/previous/$remFile > $dstlogsPath/$filename1/$symthomdir/previous/error/$newFile
	done
done

rm -rf $dstlogsPath/$filename1/home
