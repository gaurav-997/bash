#!/bin/bash

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
user="$1"
server="$2"
remote_dir="$4"
source_dir="$3"

if [[ -z $remote_dir ]] || [[ -z $source_dir ]]; then
   echo "Provide source and remote directory both"
   exit 1
fi

readable=`curl -i -X POST "sftp://ftp.lucent.com/home2/ricatt/" -K- <<< "--user ricatt:Att_Ric&7" | awk '{print$9}' | grep -i Logs`
echo $readable
filename_all=($readable)
for filename in "${filename_all[@]}"
do
	if [ -e /data/Logs_ATT/$filename ]
	then
	    echo "$filename already present"
	else
	   cd /data/Logs_ATT;curl "sftp://ftp.lucent.com/home2/ricatt/$filename" -O /data/Logs_ATT/ -K- <<< "--user ricatt:Att_Ric&7" 
	fi
done
echo "Done. files got with $server"

# Remove the sftp batch file
exit 0
