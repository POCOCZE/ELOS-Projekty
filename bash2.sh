#!/bin/bash
# Script shows Home directory, type of terminal used and all services that started at runlevel3 on the system
# Used for learning purposes
# Created by simon
# Date: 2024/8/8

echo "Homepath: $HOME"
echo

echo "Terminal type: $TERM"
echo

echo "All services started up in runlevel3 on system:"
ls /etc/rc3.d/S* | grep ss
echo

echo Quitting $TERM $PATH $HOME
ip a
