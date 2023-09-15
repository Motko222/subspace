#!/bin/bash

echo "Running nodes:"
ps aux | grep subspace-node | grep -v grep | awk 'match($0, /subspace[0-9]|subspace[0-9][0-9]/) {print $2" "substr($0, RSTART, RLENGTH)}'
read -p "Node? " node
process=$(ps aux | grep subspace-node | grep -v grep | grep "subspace$node " | awk '{print $2}')
echo "Killing process $process..."
kill $process
