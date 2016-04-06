function shuffle_detections(Detections::Array{Array{Float64,1},1}, T::Int64)


  Data = deepcopy(Detections)

  ### Simulate the shuffled order of detection arrival
  for t=1:T
    Data[t] = shuffle(Data[t])
  end

 return Data

end #shuffled_detections
