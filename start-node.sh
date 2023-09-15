#!/bin/bash

if [ -z $1 ]; then read -p "node ($ssFilter)?  " id; else id=$1; fi
source ~/config./subspace.sh $id
echo "starting node $id ($base $node $type $chain $base $port $wsport $name $peers)"
cd $ssexec;
case $type in
  arch) ./$node --chain $chain --base-path $base --execution wasm --state-pruning archive --validator --port $port --rpc-port $wsport \
     --in-peers $peers --in-peers-light $peers --out-peers $peers --name $name &> ~/logs/subspace_node$id.log & ;;
  full) ./$node --chain $chain --base-path $base --execution wasm --state-pruning 1024 --keep-blocks 1024 --validator --port $port --rpc-port $wsport \
     --in-peers $peers --in-peers-light $peers --out-peers $peers --name $name &> ~/logs/subspace_node$id.log & ;;
esac
