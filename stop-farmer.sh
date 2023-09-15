#!/bin/bash

if [ -z $1 ]
  then 
    echo "Running farmers:"
    ps aux | grep subspace-farmer | grep -v grep | awk 'match($0, /subspace[0-9]|subspace[0-9][0-9]/) {print substr($0, RSTART, RLENGTH)}'
    echo "------------------------"
    read -p "Farmer?  " id
    echo "------------------------"
  else 
    id=$1
fi

process=$(ps aux | grep subspace-node | grep -v grep | grep "subspace$id " | awk '{print $2}')
echo "Killing process $process..."
kill $process
