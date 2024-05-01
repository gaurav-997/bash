#!/bin/bash
name=${1}
age=${2}
echo "My name is ${name} and I am ${age} years old"
echo  $#
echo $@

read -p "please enter your name " name
name=${name:-Sohan}     # if user not provides any argument then sohan is the default argument
echo ${name}
