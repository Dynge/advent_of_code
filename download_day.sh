#!/bin/bash

read -p "December day: " DAY_NUM

YEAR=2022
YEAR_DIR="$HOME/git/advent_of_code/$YEAR"
if [[ !( -d $YEAR_DIR ) ]]; then
  # If directory does not exist - create it
  echo "Creating directory '$YEAR_DIR'..."
  mkdir $YEAR_DIR
fi

SESSION_COOKIE=`cat $HOME/git/advent_of_code/session_cookie.txt`
echo "Downloading data into '$YEAR_DIR/day$DAY_NUM.txt'..."
curl -H "Cookie: $SESSION_COOKIE" https://adventofcode.com/$YEAR/day/$DAY_NUM/input > "$YEAR_DIR/day$DAY_NUM.txt"
