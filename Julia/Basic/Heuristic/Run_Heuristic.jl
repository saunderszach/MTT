function run_heuristic(Data::Vector{Vector{Float64}},
                       P::Int64,
                       T::Int64,
                       Num_starting_points::Int64,
                       M::Array{Float64,2})

  (Best_Objective, Best_partitions) = heuristic_swap(Data, P, T, M);

  for i = 1:Num_starting_points
    (New_Objective, New_partitions) = heuristic_swap(Data, P, T, M);
    if New_Objective < Best_Objective
        Best_Objective = New_Objective
        Best_partitions = deepcopy(New_partitions)
      #=
      for t = 1:T
        Best_partitions[t] = copy(New_partitions[t])
      end
      =#
    end
  end

  return Best_partitions

end
