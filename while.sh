#!/bin/bash
echo -e "My name is gaurav Chauhan \n saurabh chauhan" | while read line
do
	echo "$line"
done

b=1
until [[ $b -eq 10 ]]
do
	echo "the value of b is $b"
	((b++))
done
