#!/bin/bash

echo "Hello world!"
echo "Also, Hello $USER!"

echo "Here is a list of connected users:"
w
echo

echo "I chose a colour"
COLOUR="pink"
echo

echo "Now you write number you want:"
read NUMBER
echo

echo "Here are the results"
echo "Colour: $COLOUR, Number: $NUMBER"
echo
echo "DONE!"
