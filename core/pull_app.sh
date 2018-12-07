#!/usr/bin/env bash

cd app 
git checkout master && git pull
cd ..
git add app 
git commit app -m "Updated core to latest"

