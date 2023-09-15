#!/bin/bash

if [ -z $1 ]; then read -p "node ($ssFilter)?  " id; else id=$1; fi
tail -f ~/logs/subspace_farmer$id.log
