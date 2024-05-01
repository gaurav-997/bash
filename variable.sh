#!/bin/bash

info="my name is gaurav"
echo $info
infoLength=${#info}          # Variable Syntax :-      variable_name=${<command>}    ( no space befor and after = )
echo "length of info  is  $infoLength"     # calling of any variable is without curly braces 

echo "the upper case is ${info^^}"    # it will print the whole info string into upper case 
echo "the lower case is  ${info,,}"     # it will print the whole info string into lower case 

new_info=${info/gaurav/sohan}     # replacing the gaurav by sohan in the string info 
echo "$new_info"


current_dir=`pwd`

echo "my current working directory is ${current_dir}"

date_time=$(date +"%D-%T")
echo ${date_time}
