#!/bin/bash

ansible-playbook -v -c local -i localhost, install.yml $@
