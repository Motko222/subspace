#!/bin/bash

if [ -z $1 ]
  then 
    echo "Running nodes:"
    ps aux | grep subspace-node | grep -v grep | awk 'match($0, /subspace[0-9]|subspace[0-9][0-9]/) {print substr($0, RSTART, RLENGTH)}'
    echo "------------------------"
    read -p "Node?  " id
    echo "------------------------"
  else 
    id=$1
  fi

source ~/config/subspace.sh $id

fpid=$(ps aux | grep -w $base | grep subspace-farmer-ubuntu | awk '{print $2}')
if [ ! -z $fpid ]
  then 
    echo "killing farmer "$fpid
    kill -9 $fpid 
  else 
    echo "farmer not running"
fi

npid=$(ps aux | grep -w $base | grep subspace-node-ubuntu | awk '{print $2}')
if [ ! -z $npid ]
  then 
    echo "killing node "$npid
    kill -9 $npid
    sleep 5s
  else 
    echo "node not running"
fi

cd ~/scripts/subspace
echo "starting node"
./start-node.sh $id
sleep 10s
echo "starting farmer"
./start-farmer.sh $id
