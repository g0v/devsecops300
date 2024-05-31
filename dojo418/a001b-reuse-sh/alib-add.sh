#!/bin/sh

# Function to add two integers
add() {
  local num1=$1
  local num2=$2
  local result=$((num1 + num2))
  echo "$result"
}