#!/bin/bash

if [ -z $1 ]
  then 
    echo "Running nodes:"
    ps aux | grep subspace-node | grep -v grep | awk 'match($0, /subspace[0-9]|subspace[0-9][0-9]/) {print substr($0, RSTART, RLENGTH)}' | sed 's/subspace//g'
    echo "------------------------"
    echo "Running farmers:"
    ps aux | grep subspace-farmer | grep -v grep | awk 'match($0, /subspace[0-9]|subspace[0-9][0-9]/) {print substr($0, RSTART, RLENGTH)}' | sed 's/subspace//g'
    echo "------------------------"
    read -p "Farmer?  " id
    echo "------------------------"
  else 
    id=$1
fi

source ~/scripts/subspace/config/env
source ~/scripts/subspace/config/node$id
echo "Starting farmer $id ($base $rpc $reward $size)"
cd $ssexec;
./$farmer farm --node-rpc-url $rpc --reward-address $reward path=$base,size=$size &>> ~/logs/subspace_farmer$id.log &
sleep 1s
tail -f ~/logs/subspace_farmer$id
