#!/bin/sh

# Function to add two integers
add() {
  local num1=$1
  local num2=$2
  echo $((num1 + num2))
}

result=$(add "$1" "$2")
echo $result