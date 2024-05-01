#!/bin/bash

# file is a bash variable set to the first parameter
file=$1

# now start gnuplot and pass variables and commands to it in a "heredoc"
gnuplot <<EOF
set terminal png size 1200,800
set output "$file"
set title "$3"
set xlabel "$4"
set ylabel "$5"
set grid
plot '$2' with lp
EOF
