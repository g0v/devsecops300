#!/bin/sh

# Source the add function script
source ./alib-add.sh

result=$(add "$1" "$2")
echo "The sum of $1 and $2 is $result"