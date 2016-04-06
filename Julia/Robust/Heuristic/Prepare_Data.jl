function prepare_data(Data::Vector{Vector{Float64}}, 
                      Num_Detections::Array{Int64,1}, 
                      P::Int64, 
                      T::Int64)

  New_Data = deepcopy(Data)

  Lengths = zeros(Int64,T)

  for t = 1:T
    for i = 1:Num_Detections[t]
      push!(New_Data[t],-1000)
    end

    while length(New_Data[t]) < P
      push!(New_Data[t],-1000)
    end

    Lengths[t] = length(New_Data[t])
  end

  return New_Data, Lengths
end
