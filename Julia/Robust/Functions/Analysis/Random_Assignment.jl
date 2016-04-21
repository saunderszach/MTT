function random_assignment(Partitions::Vector{Vector{Float64}},
                           T::Int64)

  Random_partitions = deepcopy(Partitions)

  for t = 1:T
    Random_partitions[t][:] = shuffle(Random_partitions[t][:])
  end

  return Random_partitions

end
