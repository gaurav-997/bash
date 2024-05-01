#!/bin/bash

action=${1}

echo "press d for date"
echo "press p for path"
echo "press l for files"

if [[ ${action} == "d" ]]
then
    echo "print the date"
date
elif [[ ${action} == "p" ]]
then
    echo "print the path"
pwd
elif [[ ${action} == "l" ]]
then  
    echo "print the files"
ls -lrt

fi

# method 2
case ${action} in
    d)
    echo "print the date"
    date ;;
    p)
    echo "print the path"
    pwd ;;
    l)
    echo "print the files"
    ls -lrt ;;
esac