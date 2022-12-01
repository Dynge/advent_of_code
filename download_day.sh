#!/bin/bash

read -p "December day: " DAY_NUM

YEAR=2022
DAY_DIR="$HOME/git/advent_of_code/$YEAR/day$DAY_NUM"
if [[ !( -d $DAY_DIR ) ]]; then
  # If directory does not exist - create it
  echo "Creating directory '$DAY_DIR'..."
  mkdir $DAY_DIR
fi

SESSION_COOKIE=`cat $HOME/git/advent_of_code/session_cookie.txt`
echo "Downloading data into '$DAY_DIR/data.txt'..."
curl -H "Cookie: $SESSION_COOKIE" https://adventofcode.com/$YEAR/day/$DAY_NUM/input > "$DAY_DIR/data.txt"
