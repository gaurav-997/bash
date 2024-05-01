#!/bin/bash
echo "Please enter your name"
read name    # read <variable name >
echo "My name is ${name} "
read -p "please enter your age " age
echo "I am ${age} years old"
read -p "please enter your password " -s password

echo "  my password is ${password}"
