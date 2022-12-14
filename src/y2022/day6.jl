module Day6

export day6, day6_sets


function create_signal_regex(distinct_chars_count)
  regex_parts = ["(?:"]
  for regex_group in 1:distinct_chars_count-1
    dont_repeat_count = distinct_chars_count - (regex_group + 1)
    push!(regex_parts, "([a-z])(?:(?!.{0,$dont_repeat_count}\\$regex_group))")
  end
  push!(regex_parts, "([a-z]))")

  return Regex(join(regex_parts))
end

function day6()
  # Import data
  data = open(f -> chomp(read(f, String)), "./2022/day6.txt", "r");

  #################

  start_of_packet_marker_length = 4
  four_distinct_regex = create_signal_regex(start_of_packet_marker_length)
  start_of_packet_marker = match(four_distinct_regex, data)

  results = [start_of_packet_marker.offset+(start_of_packet_marker_length-1)]

  ###################

  start_of_message_marker_length = 14
  fourteen_distinct_regex = create_signal_regex(start_of_message_marker_length)
  start_of_message_marker = match(fourteen_distinct_regex, data)

  push!(results, start_of_message_marker.offset+(start_of_message_marker_length-1))
  println("Day 6 Results - ", results)
end


function day6_sets()
  # Import data
  data = open(f -> chomp(read(f, String)), "./2022/day6.txt", "r");

  #################
  packet_len = 4
  for index in packet_len+1:length(data)
    if length(Set(data[index-(packet_len-1):index])) == packet_len
      println("Part 1 -- ", index)
      break
    end
  end

  ###################

  message_len = 14
  for index in message_len+1:length(data)
    if length(Set(data[index-(message_len-1):index])) == message_len
      println("Part 2 -- ", index)
      break
    end
  end
end

end
