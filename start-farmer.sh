#!/bin/bash

if [ -z $1 ]; then read -p "node ($ssFilter)?  " id; else id=$1; fi
source ~/config/subspace.sh $id
echo "starting farmer $id ($base $rpc $reward $size)"
cd $ssexec;
./$farmer farm --node-rpc-url $rpc --reward-address $reward path=$base,size=$size &>> ~/logs/subspace_farmer$id.log &
