#!/bin/sh

set -e

cd engine || exit 1

mkdir -p build
cd build

cmake .. || exit 1

make || exit 1

if [ -f ./libengine.so ]; then
    sudo cp -f ./libengine.so /usr/local/lib/ || exit 1
else 
    exit 1
fi