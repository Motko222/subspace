#!/bin/bash

if [ -z $1 ]
  then 
    echo "Running nodes:"
    ps aux | grep subspace-node | grep -v grep | awk 'match($0, /subspace[0-9]|subspace[0-9][0-9]/) {print substr($0, RSTART, RLENGTH)}' | sed 's/subspace//g'
    echo "------------------------"
    read -p "Node?  " id
    echo "------------------------"
  else 
    id=$1
  fi

source ~/scripts/subspace/config/node$id

fpid=$(ps aux | grep -w $base | grep subspace-farmer-ubuntu | awk '{print $2}')
if [ ! -z $fpid ]
  then 
    echo "Stopping farmer process "$fpid
    kill $fpid 
  else 
    echo "Farmer not running"
fi

npid=$(ps aux | grep -w $base | grep subspace-node-ubuntu | awk '{print $2}')
if [ ! -z $npid ]
  then 
    echo "Stopping node process "$npid
    kill $npid
    sleep 5s
  else 
    echo "Node not running"
fi

cd ~/scripts/subspace
./start-node.sh $id
sleep 10s
./start-farmer.sh $id
