#!/bin/bash
#
# THis script reads positional parameters and prints them out

PARAM1="$1"
PARAM2="$2"

echo "$1 is the first positional parameter, $1, or \$1."
echo "$2 is the second positional parameter, $2, or \$2"

echo "The total number of parameter are ther sums by using \$# is $#."
echo

echo "Script ended."
