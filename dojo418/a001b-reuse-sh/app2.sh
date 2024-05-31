#!/bin/sh

# Source the add function script
source ./alib-add.sh

result=$(add "$1" "$2")
echo $result