#!/bin/bash

if [ -z $1 ]
  then 
    echo "Configured nodes:"
    ls ~/scripts/subspace/config | grep node
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
cd $ssexec;
case $type in
  arch) ./$node --chain $chain --base-path $base --execution wasm --state-pruning archive --validator --port $port --rpc-port $wsport \
     --in-peers $peers --in-peers-light $peers --out-peers $peers --name $name &> ~/logs/subspace_node$id.log & ;;
  full) ./$node --chain $chain --base-path $base --execution wasm --state-pruning 1024 --keep-blocks 1024 --validator --port $port --rpc-port $wsport \
     --in-peers $peers --in-peers-light $peers --out-peers $peers --name $name &> ~/logs/subspace_node$id.log & ;;
esac
