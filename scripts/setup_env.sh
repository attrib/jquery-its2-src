#!/bin/sh
sudo apt-get install git-core curl build-essential openssl libssl-dev
cd /tmp
git clone https://github.com/joyent/node.git && cd node
git checkout v0.9.9
./configure
sudo make install
cd /tmp
curl http://npmjs.org/install.sh | sudo sh
sudo npm install -g coffee-script
sudo npm install -g uglify-js
sudo npm install -g phantomjs