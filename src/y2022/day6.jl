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
  println("Part 1:")

  start_of_packet_marker_length = 4
  four_distinct_regex = create_signal_regex(start_of_packet_marker_length)
  start_of_packet_marker = match(four_distinct_regex, data)

  println(
          "The (0-based) index of the first start-of-packet signal is at: ",
          start_of_packet_marker.offset+(start_of_packet_marker_length-1)
         )

  ###################
  println("Part 2:")

  start_of_message_marker_length = 14
  fourteen_distinct_regex = create_signal_regex(start_of_message_marker_length)
  start_of_message_marker = match(fourteen_distinct_regex, data)

  println(
          "The (0-based) index of the first start-of-message signal is at: ",
          start_of_message_marker.offset+(start_of_message_marker_length-1)
         )
end


function day6_sets()
  # Import data
  data = open(f -> chomp(read(f, String)), "./2022/day6.txt", "r");

  #################
  println("Part 1:")

  packet_len = 4
  for index in packet_len+1:length(data)
    if length(Set(data[index-(packet_len-1):index])) == packet_len
      println(
              "The (0-based) index of the first start-of-packet signal is at: ",
              index
             )
      break
    end
  end

  ###################
  println("Part 2:")

  message_len = 14
  for index in message_len+1:length(data)
    if length(Set(data[index-(message_len-1):index])) == message_len
      println(
              "The (0-based) index of the first start-of-message signal is at: ",
              index
             )
      break
    end
  end
end

end
