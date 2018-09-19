#!/bin/bash -e

version="2.1.1"
url="https://github.com/go-task/task/releases/download/v${version}/task_linux_amd64.tar.gz"

which task > /dev/null && exit

cd /tmp || exit
wget ${url} 
tar -xzf task_linux_amd64.tar.gz
sudo install task /usr/local/bin
