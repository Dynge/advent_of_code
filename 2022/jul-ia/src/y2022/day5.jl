module Day5

export day5

function extract_blocks(row_block_in_strings)
    crate_vectors::Vector{Vector{Char}} = [[] for _ in 1:9]
    data_cols = 2:4:length(row_block_in_strings[1])-1
    for string in reverse(row_block_in_strings)
        for (block_num, col) in enumerate(data_cols)
            if string[col] != ' '
                append!(crate_vectors[block_num], string[col])
            end
        end
    end

    return crate_vectors
end


function extract_moves(move_data_strings)
    moves_vectors::Vector{Vector{Int64}} = map(x -> parse.(Int, x),
        map(split,
            map(x -> replace(x, r"[^0-9 ]" => ""), move_data_strings)
        )
    )
    return moves_vectors

end


function perform_moves_cratemover_9000(crate_vectors, moves_vector)
    copy_vectors = deepcopy(crate_vectors)
    for (count, from, to) in moves_vector
        for _ in 1:count
            char = pop!(copy_vectors[from])
            append!(copy_vectors[to], char)
        end
    end
    return copy_vectors
end


function perform_moves_cratemover_9001(crate_vectors, moves_vector)
    copy_vectors = deepcopy(crate_vectors)
    for (count, from, to) in moves_vector
        move_list = copy_vectors[from][end-(count-1):end]
        copy_vectors[from] = copy_vectors[from][begin:end-count]
        append!(copy_vectors[to], move_list)
    end
    return copy_vectors
end


function day5()
    # Import data
    data = open(readlines, "./2022/day5.txt", "r")
    row_block_strings = map(x -> replace(x, r"\[|\]" => " "), data[1:8])

    #################
    crate_vectors = extract_blocks(row_block_strings)
    moves_vector = extract_moves(data[11:end])

    cratemover9000_vectors = perform_moves_cratemover_9000(crate_vectors, moves_vector)
    top_crates = join(map(pop!, cratemover9000_vectors))

    results = [top_crates]

    ###################
    cratemover9001_vectors = perform_moves_cratemover_9001(crate_vectors, moves_vector)
    top_crates = join(map(pop!, cratemover9001_vectors))

    push!(results, top_crates)
    println("Day 5 Results - ", results)
end

end
