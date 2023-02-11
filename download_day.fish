#!/bin/fish

read -l -P "December day: " DAY_NUM

set YEAR 2022
set YEAR_DIR "$HOME/git/advent_of_code/$YEAR"
if not test -d $YEAR_DIR
  # If directory does not exist - create it
  echo "Creating directory '$YEAR_DIR'..."
  mkdir $YEAR_DIR
end

set SESSION_COOKIE (cat $HOME/git/advent_of_code/session_cookie.txt)
echo "Downloading data into '$YEAR_DIR/day$DAY_NUM.txt'..."
curl -H "Cookie: $SESSION_COOKIE" https://adventofcode.com/$YEAR/day/$DAY_NUM/input > "$YEAR_DIR/day$DAY_NUM.txt"
