#!/bin/bash

VERSION="$1"

cd /home/mpro

mkdir -p build

echo "Checking current process..."
if [ $(pm2 ls | grep "www" | wc -l) > 0 ]; then
    echo "There is a process running, so it will be removed to proceed the installation"
    npm run pm2:remove
    
    echo "Removing previous source files..."
    rm -rf config node_modules package.json src
fi

echo "Copying version $VERSION..."
cp /home/deploy/$VERSION.tgz /home/mpro/build

cd /home/mpro/build

echo "Extracting source files..."
tar zxvf $VERSION.tgz -C .

mv $VERSION/* ../
rm -rf $VERSION

cd ..

npm install && npm run pm2:start