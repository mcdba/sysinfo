#!/bin/bash

while [[ -n $1 ]]; do
    echo "$1	ALL=(ALL) NOPASSWD: /usr/sbin/tcpdump,/bin/netstat" >> /etc/sudoers;
    shift # shift all parameters;
done