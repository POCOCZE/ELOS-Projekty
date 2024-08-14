#!/bin/bash
# To learn bash effectively its essential to know how to work with functions
# Usage of functions privides a lot of benefits:
# - Better readibility
# - Avoid duplicates in code
# - Code is easier to read and maintain
# by: simon

greet() {
    echo "Hello, world"
}

greet

greetings() {
    local name="$1"
    echo "Hello, $name"
}

#echo "Write please your name"
#read $MYNAME
#greetings $MYNAME

greetings "Tom"

addiction() {
    local num1="$1"
    local num2="$2"
    local result=$((num1 + num2))
    echo $result
}

sum=$(addiction 3 6)
echo "The sum is $sum"

