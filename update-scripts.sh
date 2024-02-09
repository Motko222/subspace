#!/bin/bash

cd ~/scripts/subspace
git stash push --include-untracked
git pull
chmod +x *.sh
