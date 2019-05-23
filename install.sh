#!/bin/bash

GO_VERSION="1.12.5"        # https://golang.org/dl/
FILEBEAT_VERSION="a8ab26d" # https://github.com/elastic/beats/releases

# Install prerequisites
sudo apt update -y
sudo apt install -y python-pip git
sudo pip install virtualenv

# Get & install go
cd $HOME
wget https://dl.google.com/go/go${GO_VERSION}.linux-armv6l.tar.gz
sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-armv6l.tar.gz
export PATH=$PATH:/usr/local/go/bin
echo "export PATH=$PATH:/usr/local/go/bin" >> $HOME/.bashrc

# Get & install filebeat
export GOPATH=$HOME/go
mkdir -p $GOPATH/src/github.com/elastic
cd $GOPATH/src/github.com/elastic
git clone https://github.com/elastic/beats.git
cd beats
git checkout $FILEBEAT_VERSION
cd filebeat
make && make update

if ! test -x ./filebeat ; then
  echo "Build failed somehow. Now it's job to find out why..."
  exit 1
fi

sudo mv filebeat /usr/share/filebeat/bin
sudo mv module /usr/share/filebeat/
sudo mv modules.d/ /etc/filebeat/
sudo cp filebeat.yml /etc/filebeat/
sudo chmod 750 /var/log/filebeat
sudo chmod 750 /etc/filebeat/
sudo chown -R root:root /usr/share/filebeat/*

sudo cp filebeat.service /lib/systemd/system/filebeat.service

sudo systemctl daemon-reload
sudo systemctl enable filebeat
sudo systemctl start filebeat
