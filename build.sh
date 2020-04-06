#!/bin/bash

for i in $(find -maxdepth 1 -type d ! -path '.')
do
    pushd $i
        ./build.sh
    popd
done
