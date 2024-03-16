#!/bin/bash

min_conv () {
 a=$1
 case $a in
  "")  out=" " ;;
  "never") out="never" ;;
  0) out="now" ;;
  [1-9]|[1-9][0-9]|1[0-1][0-9]) out=$a"m" ;; #1-119
  1[2-9][0-9]|[2-9][0-9][0-9]|1[0-9][0-9][0-9]|2[0-7][0-9][0-9]|28[0-7][0-9]) out=$((a/60))"h"  ;; #120-2879
  *) out=$((a/60/24))"d" ;;
  esac
 echo $out
}

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

source ~/scripts/subspace/config/env
source ~/scripts/subspace/config/node$id

name="subspace"$id
id="subspace-"$id
bucket=node
nlog=~/logs/subspace_node$id
flog=~/logs/subspace_farmer$id

fpid=$(ps aux | grep -w $base | grep subspace-farmer-ubuntu | awk '{print $2}')
npid=$(ps aux | grep -w $base | grep subspace-node-ubuntu | awk '{print $2}')
#chain=$(cat $nlog | grep "Chain specification" | tail -1 | awk -F 'Subspace ' '{print $2}')

currentblock=$(curl -s -H "Content-Type: application/json" -d '{"id":1, "jsonrpc":"2.0", "method": "system_syncState", "params":[]}' http://localhost:$wsport | jq -r ".result.currentBlock")
if [ -z $currentblock ]; then currentblock=0; fi
#bestblock=$(curl -s -H  POST 'https://subspace.api.subscan.io/api/scan/metadata' --header 'Content-Type: application/json' --header 'X-API-Key: $apiKey' | jq -r .data.blockNum )
bestblock=$(curl -s -H "Content-Type: application/json" -d '{"id":1, "jsonrpc":"2.0", "method": "system_syncState", "params":[]}' http://localhost:$wsport | jq -r ".result.highestBlock")
if [ -z $bestblock ]; then bestblock=0; fi
diffblock=$(($bestblock-$currentblock))
plotted=$(cat $flog | grep --line-buffered --text "Plotting sector " | tail -1 | awk -F "Plotting sector " '{print $2}' | awk '{print $1}' | sed 's/(\|)//g')

temp1=$(grep --line-buffered --text -E "Idle|Syncing|Preparing" $nlog | tail -1)
bdate=$(echo $temp1 | awk '{print $1}')T$(echo $temp1 | awk '{print $2}').000+0200
#bmin=$((($(date +%s)-$(date -d $bdate +%s))/60))
peers=$(echo $temp1 | awk -F " peers" '{print $1}' | awk -F " \(" '{print $2}')
syncSpeed=$(grep --line-buffered --text "Syncing" $nlog | tail -1 | awk -F "Syncing" '{print $2}' | awk -F "," '{print $1}')

#temp2=$(grep --line-buffered --text "Successfully signed reward hash" $flog | tail -1 | sed -r 's/\x1B\[(;?[0-9]{1,3})+[mGK]//g' )
#if [ -z $temp2 ]
#then
# rmin="never";
#else
# rdate=$(echo $temp2 | awk '{print $1}');
# rmin=$((($(date +%s)-$(date -d $rdate +%s))/60))
#fi

rew1=$(cat $flog | grep -a 'Successfully signed reward hash' | grep -c $(date -d "today" '+%Y-%m-%d'))
rew2=$(cat $flog | grep -a 'Successfully signed reward hash' | grep -c $(date -d "yesterday" '+%Y-%m-%d'))
rew3=$(cat $flog | grep -a 'Successfully signed reward hash' | grep -c $(date -d "2 days ago" '+%Y-%m-%d'))
rew4=$(cat $flog | grep -a 'Successfully signed reward hash' | grep -c $(date -d "3 days ago" '+%Y-%m-%d'))
#address=${address1:0:4}...${address1: -4}
size=$(ps aux | grep -w $base | grep subspace-farmer-ubuntu | awk -F 'size=' '{print $2}'| awk '{print $1}')
folder=$(du -hs $base | awk '{print $1}')
archive=$(ps aux | grep -w $base | grep subspace-node-ubuntu | grep -c archive)
#version=$(cat $nlog | grep version | awk '{print $5}' | head -1 | cut -d "-" -f 1 )
version=$(ps aux | grep subspace-node-ubuntu | grep $base | awk -F "2024-" '{print $2}' | awk '{print $1}')
balance=$(curl -s POST 'https://subspace.api.subscan.io/api/scan/account/tokens' --header 'Content-Type: application/json' \
 --header 'X-API-Key: '$apiKey'' --data-raw '{ "address": "'$reward'" }' | jq -r '.data.native' | jq -r '.[].balance' | awk '{print $1/1000000000000000000}')

if [ -z $balance ]
  then balance="0"
fi

if [ $diffblock -le 5 ]
  then 
    status="ok"
    message="size $size rewards $rew1-$rew2-$rew3-$rew4, balance $balance, plotted $plotted, peers $peers"
  else 
    status="warning"
    message="sync $currentblock/$bestblock, peers=$peers, $syncSpeed"; 
fi

if [ $bestblock -eq 0 ]
  then 
    status="warning"
    message="cannot fetch network height"
fi

if [ -z $fpid ]
  then 
    status="warning"
    message="farmer not running, sync $currentblock/$bestblock, peers $peers, $syncSpeed"
fi

if [ -z $npid ]
  then 
    status="error"
    message="node not running"
fi

#echo "updated:           " $(date +'%y-%m-%d %H:%M')
#echo "network:           " $chain
#echo "status:            " $status
#echo "last_block_time:   " $bdate
#echo "last_block_age:    " $(min_conv $bmin)
#echo "node_height:       " $currentblock
#echo "network_height:    " $bestblock
#echo "peers:             " $peers
#echo "last_reward_time:  " $rdate
#echo "last_reward_age:   " $(min_conv $rmin)
#echo "rewards_daily:     " $rew1 $rew2 $rew3 $rew4
#echo "reward_address:    " $reward
#echo "plot_size:         " $size
#echo "folder_size:       " $folder
#echo "base_folder:       " $base
#echo "farmer_process:    " $fpid
#echo "node_process:      " $npid
#echo "archive_node:      " $archive
#echo "version:           " $version
#echo "balance:           " $balance
#echo "type:              " $type
#echo "message:              " $message

echo "version='$version'"
echo "status=$status"
echo "message='$message'"
echo "network='$chain'"
echo "type='$type'"
echo "folder=$folder"

cat << EOF
{
  "id":"$id",
  "machine":"$MACHINE",
  "chain":"$chain",
  "version":"version",
  "status":"$status",
  "message":"$message",
  "fpid":"$fpid",
  "npid":"$npid",
  "peers":"$peers",
  "syncSpeed":"$syncSpeed", 
  "plotted":"$plotted",
  "bestblock":"$bestblock",
  "currentblock":"$currentblock",
  "balance":"$balance",
  "updated":"$(date --utc +%FT%TZ)"
}
EOF

# send data to influxdb
if [ ! -z $INFLUX_HOST ]
then
 curl --request POST \
 "$INFLUX_HOST/api/v2/write?org=$INFLUX_ORG&bucket=$bucket&precision=ns" \
  --header "Authorization: Token $INFLUX_TOKEN" \
  --header "Content-Type: text/plain; charset=utf-8" \
  --header "Accept: application/json" \
  --data-binary "
    status,node=$id,machine=$MACHINE status=\"$status\",message=\"$message\",version=\"$version\",url=\"$url\",chain=\"$chain\" $(date +%s%N) 
    "
fi
