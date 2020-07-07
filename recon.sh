#!/bin/bash

#Usage
if [ -z "$1" ]
then
        echo "Usage: ./recon.sh <IP>"
        exit 1
fi

#Make new folder
echo "Machine name (for folder): "
read NAME
mkdir $NAME

printf "\n----- NMAP Quick -----\n\n" > $NAME/results

#Quick NMap scan with instant output
echo "Running Quick NMap..."
nmap $1 | tail -n +5 | head -n -3 >> $NAME/results
cat $NAME/results && printf "\n"

printf "\n----- NMAP Normal -----\n\n" >> $NAME/results

#Normal NMap scan with more detail
echo "Running Normal NMap"
nmap -sC -sV -oA $NAME/nmap $1 | tail -n +5 | head -n -3 >> $NAME/results

#Run gobuster if HTTP port is found
while read line
do
        if [[ $line == *open* ]] && [[ $line == *http* ]]
        then
                echo "Running Gobuster..."
                gobuster dir -u $1 -w /usr/share/wordlists/dirb/common.txt -qz > $NAME/temp1

        fi
done < $NAME/results

if [ -e $NAME/temp1 ]
then
        printf "\n----- DIRS -----\n\n" >> $NAME/results
        cat $NAME/temp1 >> $NAME/results
        rm $NAME/temp1
fi

#Output results to user
cat $NAME/results
