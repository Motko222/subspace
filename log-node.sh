#!/bin/bash

if [ -z $1 ]
  then 
    echo "Running nodes:"
    ps aux | grep subspace-node | grep -v grep | awk 'match($0, /subspace[0-9]|subspace[0-9][0-9]/) {print substr($0, RSTART, RLENGTH)}'  | sed 's/subspace//g'
    echo "------------------------"
    read -p "Node?  " id
    echo "------------------------"
  else 
    id=$1
fi

tail -f ~/logs/subspace_node$id
