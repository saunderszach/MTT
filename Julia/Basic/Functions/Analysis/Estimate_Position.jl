function estimate_positions(Data::Vector{Vector{Float64}},
                            Estimated_partitions::Vector{Vector{Float64}},
                            P::Int64,
                            T::Int64)

  (Objective, Alpha, Beta) = solve_estimation(Data, Estimated_partitions, P, T)

  Estimated_positions = Vector{Float64}[Float64[Alpha[i] + Beta[i]*(t) for i in 1:P] for t in 1:T]

  return Estimated_positions, Objective

end

