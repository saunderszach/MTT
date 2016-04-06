function random_assignment(Ideal_partitions::Vector{Vector{Float64}},
                           T::Int64)

  Random_partitions = deepcopy(Ideal_partitions)

  for t = 1:T
    Random_partitions[t][:] = shuffle(Random_partitions[t][:])
  end

  return Random_partitions

end
