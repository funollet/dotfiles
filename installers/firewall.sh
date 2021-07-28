#!/bin/bash

sudo firewall-cmd --get-services | grep -q emby \
    sudo firewall-cmd --permanent --new-service-from-file=files/emby.xml

sudo firewall-cmd --list-services | grep -q emby \
    firewall-cmd --permanent --add-service=emby

sudo systemct restart firewalld
