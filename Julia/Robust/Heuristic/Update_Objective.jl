function update_obj(RSS, 
                    Total_FA, 
                    Total_MD, 
                    Swap_Index, 
                    Partitions::Vector{Vector{Float64}}, 
                    P::Int64, 
                    t::Int64, 
                    T::Int64)

Temp_Partitions = cell(T)
for j = 1:T
    Temp_Partitions[j] = copy(Partitions[j])
end

if Swap_Index[2] > P
  if Temp_Partitions[t][Swap_Index[1]] == -1000 && Temp_Partitions[t][Swap_Index[2]] != -1000
      Total_FA = Total_FA - 1
      Total_MD = Total_MD - 1
  elseif Temp_Partitions[t][Swap_Index[1]] != -1000 && Temp_Partitions[t][Swap_Index[2]] == -1000
      Total_FA = Total_FA + 1
      Total_MD = Total_MD + 1
  end
end

## Make the hypothetical switch
Temp_Partitions[t][Swap_Index[1]],Temp_Partitions[t][Swap_Index[2]] = Temp_Partitions[t][Swap_Index[2]],Temp_Partitions[t][Swap_Index[1]]

New_RSS = copy(RSS)
for p in Swap_Index
    if p <= P

      Time = Int64[]
      Position = Float64[]

      count = 1
      for t = 1:T
        if Temp_Partitions[t][p] != -1000
          push!(Time,count)
          push!(Position,Temp_Partitions[t][p])
        end
        count = count + 1
      end

      Temp_T   = length(Time)

      if Temp_T >= 2
          X        = ones(Temp_T, 2);
          X[:,2]   = Time;
          M        = eye(Temp_T)-X*((X'X)\(X'));
          New_RSS[p] = (norm((Position')*M))^2
          #New_RSS[p] = (norm(Position- X*(X\Position)))^2
      end
  end
end

  return New_RSS, Total_FA, Total_MD
end
