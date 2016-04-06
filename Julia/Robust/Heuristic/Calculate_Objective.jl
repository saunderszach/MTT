function calc_obj(P::Int64,
                  T::Int64,
                  Partitions::Vector{Vector{Float64}}, 
                  Lengths::Array{Int64,1})

Total_FA = 0    #Set the total # of False Alarms to zero
Total_MD = 0    #Set the total # of Missed Detections to zero

for t = 1:T                  #Loop through each time step
  for j = 1:Lengths[t]       #Loop through each detection in the time step

    if Partitions[t][j] == -1000
      if j <= P
        Total_MD = Total_MD + 1
      end
    else
      if j > P
        Total_FA = Total_FA + 1
      end

    end
  end
end

RSS = zeros(P)
for p in 1:P

  Time = Int64[]
  Position = Float64[]
  index = 1

  for t = 1:T

    if Partitions[t][p] != -1000
      push!(Time,index)
      push!(Position,Partitions[t][p])
    end
    index = index + 1

  end

  Temp_T = length(Time)

  if Temp_T >= 2
      X        = ones(Temp_T, 2);
      X[:,2]   = Time;
      M        = eye(Temp_T)-X*((X'X)\(X'));

      RSS[p] = (norm((Position')*M))^2
  end
end

  return RSS, Total_FA, Total_MD

end #calculate_objective
