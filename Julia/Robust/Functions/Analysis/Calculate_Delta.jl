function calc_delta(True_trajectory::Vector{Vector{Float64}},
                    Estimated_trajectory::Vector{Vector{Float64}},
                    Assignments::Array{Int64,1},
                    P::Int64,
                    T::Int64)

  Distances = Float64[abs(True_trajectory[t][Assignments[i]] - Estimated_trajectory[t][i]) for i=1:P, t=1:T]

  Total_distance = sum(Distances)

  δ = Total_distance/(P*T)

  return δ

end
