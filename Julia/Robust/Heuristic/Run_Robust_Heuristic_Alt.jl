function run_robust_heuristic(T, P_Range, Data, Num_Detections, Num_iterations, θ, ϕ)

Objective_Scores = zeros(length(P_Range))
P_Data = cell(T)
Best_Data = cell(T)

count = 1
for p in P_Range
    P_start = time()

  for t = 1:T
    P_Data[t] = copy(Data[t])
  end

  for t = 1:T
    for i = 1:Num_Detections[t]
      push!(P_Data[t],-1000)
    end

    while length(P_Data[t]) < p
      push!(P_Data[t],-1000)
    end

    Lengths[t] = length(P_Data[t])
  end

  (Best_objective, Best_Data) = robust_heuristic_swap(p,T,P_Data, Num_Detections, Lengths, θ, ϕ)

  for i = 1:Num_iterations
    (Total_objective, New_Data) = robust_heuristic_swap(p,T,P_Data, Num_Detections, Lengths, θ, ϕ)
    if Total_objective < Best_objective
        Best_objective = Total_objective
      for t = 1:T
        Best_Data[t] = copy(New_Data[t])
      end
    end
  end

  Objective_Scores[count] = Best_objective
  count = count + 1

  P_end = time()
  P_run_time = P_end - P_start
  @printf("Time to run P=%d: %f\n", p, round(P_run_time,4))
end

  return Objective_Scores, Best_Data
end
