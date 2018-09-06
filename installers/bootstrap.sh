#!/bin/bash -e

version="2.1.0"
url="https://github.com/go-task/task/releases/download/v${version}/task_linux_amd64.rpm"

which task > /dev/null && exit

cd /tmp || exit
wget ${url} 
sudo dnf install -y task_linux_amd64.rpm

