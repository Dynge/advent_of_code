#!/bin/bash

read -p "December day: " DAY_NUM

DAY_DIR="$HOME/advent_of_code/day$DAY_NUM"
if [[ !( -d $DAY_DIR ) ]]; then
  # If directory does not exist - create it
  echo "Creating directory '$DAY_DIR'..."
  mkdir $DAY_DIR
fi

SESSION_COOKIE=`cat $HOME/advent_of_code/session_cookie.txt`
echo "Downloading data into '$DAY_DIR/data.txt'..."
curl -H "Cookie: $SESSION_COOKIE" https://adventofcode.com/2022/day/$DAY_NUM/input > "$DAY_DIR/data.txt"
