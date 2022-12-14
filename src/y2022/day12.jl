module Day12

export day12, day12_bfs, day12_dijkstra, day12_astar

using GraphPlot
using Compose
import Graphs

function load_matrix()
  data = open(readchomp, "./2022/day12.txt", "r")
  return mapreduce(permutedims, vcat, collect(map(line -> [char for char in line], split(data, "\n"))))
end

function load_graph(mat::Matrix)::Tuple{Vector, Int, Int}
  edges::Vector{Tuple{Int, Int}} = []
  start_index = 0
  end_index = 0
  for index in CartesianIndices(mat)
    if mat[index] == 'S'
      start_index = flat_index(index, mat)
    elseif mat[index] == 'E'
      end_index = flat_index(index, mat)
    end
    append!(edges, get_edges_to(index, mat))
  end

  return (edges, start_index, end_index)
end

function get_height(c::Char)
  ALPHABET = "abcdefghijklmnopqrstuvwxyz"
  alphabet_height = findfirst(c, ALPHABET)

  if alphabet_height === nothing
    alphabet_height = Dict('S' => 1, 'E' => 26)[c]
  end

  return alphabet_height
end

function flat_index(index::CartesianIndex, mat::Matrix)::Int
  return index.I[2] + (index.I[1]-1)*size(mat,2)
end


function get_edges_to(index::CartesianIndex, mat)::Vector{Tuple{Int, Int}}
  index_height = get_height(mat[index])
  index_edges_to::Vector{Tuple{Int, Int}} = []
  for neighbor in [ 
    CartesianIndex(-1, 0), CartesianIndex(1, 0), CartesianIndex(0, -1), CartesianIndex(0, 1), 
  ]
    if all(neighbor.I .== 0)
      continue
    end

    neighbor_index = index + neighbor
    if (
      any(neighbor_index.I .== 0) ||
        neighbor_index.I[1] > size(mat, 1) ||
          neighbor_index.I[2] > size(mat, 2)
    )
      continue
    end

    neighbor_height = get_height(mat[index+neighbor])
    if neighbor_height <= index_height + 1
      push!(index_edges_to, (flat_index(index, mat), flat_index(neighbor_index, mat)))
    end
  end

  return index_edges_to
end

function possible_start_positions(matrix::Matrix)::Vector{Int}
  start_pos = []
  for index in CartesianIndices(matrix)
    if get_height(matrix[index]) == 1
      push!(start_pos, flat_index(index, matrix))
    end
  end

  return start_pos
end

function day12_bfs()
  println("Part 1: ")
  mat = load_matrix()
  (edges, start_index, end_index) = load_graph(mat)
  graph = Graphs.SimpleDiGraph(Graphs.Edge.(edges))
  solution = Graphs.bellman_ford_shortest_paths(graph, start_index)
  solution.dists[end_index]
  println("Fewest steps from 'S' is: ", solution.dists[end_index])

  println("Part 2: ")
  start_pos = possible_start_positions(mat)
  solution = Graphs.bellman_ford_shortest_paths(graph, start_pos)

  println("Minimum steps from any 'a' is: ", minimum(solution.dists[end_index]))
end

function day12_dijkstra()
  println("Part 1: ")
  mat = load_matrix()
  (edges, start_index, end_index) = load_graph(mat)
  graph = Graphs.SimpleDiGraph(Graphs.Edge.(edges))
  solution = Graphs.dijkstra_shortest_paths(graph, start_index)
  println("Fewest steps from 'S' is: ", solution.dists[end_index])

  println("Part 2: ")
  start_pos = possible_start_positions(mat)
  solution = Graphs.dijkstra_shortest_paths(graph, start_pos)

  println("Minimum steps from any 'a' is: ", minimum(solution.dists[end_index]))
end

function day12_astar()

  println("Part 1: ")
  mat = load_matrix()
  (edges, start_index, end_index) = load_graph(mat)
  graph = Graphs.SimpleDiGraph(Graphs.Edge.(edges))
  solution = Graphs.a_star(graph, start_index, end_index)
  println("Fewest steps: ", length(solution))

  println("Part 2: ")
  solution_lenghts = []
  for start_pos in possible_start_positions(mat)
    solution = Graphs.a_star(graph, start_pos, end_index)
    if length(solution) == 0
      continue
    end
    push!(solution_lenghts, length(solution))
  end

  println("Minimum steps from any 'a' is: ", minimum(solution_lenghts))
end

day12() = day12_bfs()

function plot_graph(location::String)
  mat = load_matrix()
  (edges, _, _) = load_graph(mat)
  graph = Graphs.SimpleDiGraph(Graphs.Edge.(edges))
  draw(SVG(location, 50cm, 50cm), gplot(graph, arrowlengthfrac=0.01))
end




# @time main_bfs() # BFS is Dijkstra for unweighted edges
# @time main_djek() # A little slower than BFS probably because it assumes weights
# @time main_star() # A lot slower than BFS (both in part 1 and especially in part 2) (heuristic is misleading in this case, and part 2 looping is inefficient)

# plot_graph("day12.svg")
end
