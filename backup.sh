#!/bin/bash

backup_dir=("/etc" "/home") # which dir I have to take bkp
destination_dir="/root/backup_today"
mkdir -p $destination_dir
bkp_dt=`date +"%d_%B_%Y_%H_%M_%S"`
echo "starting bkp of ${backup_dir[@]}" # it will take all dir form backup_dir one by one

for i in ${backup_dir[@]}
do 
tar -cvzf /tmp/$i_$bkp_dt.tar.gz $i 
if [[ $? == 0 ]]
then
echo " $i backup is successful"
else
echo "$i backup is not successful"
fi
cp /tmp/$i_$bkp_dt.tar.gz $destination_dir
done

sudo rm /tmp/*.gz
echo "bakcup is done"