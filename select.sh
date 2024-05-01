#!/bin/bash
#select cars in bmw audi tesla landrover 
#do 
#	echo "you have selected the $cars"
#done

select action in d p l
do
	case ${action,,} in
    	d)
    	echo "print the date"
    	date ;;
    	p)
    	echo "print the path"
    	pwd ;;
    	l)
    	echo "print the files"
    	ls -lrt ;;
    	*)
    	echo "please enter correct choice" ;;
	esac
done
