function run_robust_heuristic(Data::Vector{Vector{Float64}}, 
                              Num_Detections::Array{Int64,1},
                              Lengths::Array{Int64,1}, 
                              Num_Iterations::Int64, 
                              P::Int64,
                              T::Int64,
                              θ::Float64,
                              ϕ::Float64)

  (Best_Objective, Best_Data) = robust_heuristic_swap(Data, Num_Detections, Lengths, P, T, θ, ϕ)

  for i = 1:Num_Iterations
    (New_Objective, New_Data) = robust_heuristic_swap(Data, Num_Detections, Lengths, P, T, θ, ϕ)
    if New_Objective < Best_Objective
        Best_Objective = New_Objective
        Best_Data = deepcopy(New_Data)
    end
  end
  
  return Best_Data
end
