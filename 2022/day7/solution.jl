function main()
  # Import data
  data = open(readlines, "./2022/day7/data.txt", "r");

  current_dir = ""

  command = data[1]
  for command in data
    start_command = command[1:4]
    if start_command == "\$ ls"
      continue
    elseif start_command == "\$ cd"
      if command[5:end] == ".."
        current_dir = match(r"^.+\/", current_dir)
      else
        current_dir += start_command[5:end]
      end
    elseif start_command == "dir "
      continue
    else
      continue
    end
  end
end

