#!/bin/bash

if [ -z $1 ]
  then 
    echo "Configured nodes:"
    ls ~/scripts/subspace/config | grep node | grep -v sample | sed 's/node//g'
    echo "------------------------"
    read -p "Node?  " id
    echo "------------------------"
  else 
    id=$1
  fi

source ~/scripts/subspace/config/env
source ~/scripts/subspace/config/node$id

if [ ! -d $base ] 
  then
    mkdir $base
fi

echo "Starting node $id ($base $node $type $chain $base $port $wsport $name $peers)"
cd $ssexec

 ./$node run --chain $chain --base-path $base --farmer --port $port --rpc-port $wsport \
     --in-peers $peers --in-peers-light $peers --out-peers $peers --name $name &> ~/logs/subspace_node$id &     
sleep 1s
tail -f ~/logs/subspace_node$id
