function calc_delta(True_trajectory::Vector{Vector{Float64}},
                    Estimated_trajectory::Vector{Vector{Float64}},
                    Assignments::Array{Int64,1},
                    True_P::Int64,
                    Test_P::Int64,
                    T::Int64)

 Distances = zeros(Test_P, T)

  for t = 1:T
    for p = 1:Test_P

    	if Assignments[p]!=0
    		Distances[p,t] = abs(True_trajectory[t][Assignments[p]] - Estimated_trajectory[t][p])
    	end
      
    end
  end

  Total_distance = sum(Distances)

  δ = Total_distance/(min(True_P,Test_P)*T)

  return δ

end
