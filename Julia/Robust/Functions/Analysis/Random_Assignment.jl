function random_assignment(Data::Vector{Vector{Float64}},
                           Num_detections::Array{Int64,1},
                           T::Int64) 
    
    P_test_min   = minimum(Num_detections)
    P_test_max   = maximum(Num_detections)

	Random_P = rand(P_test_min:P_test_max)
  
 	(Prepared_data, Lengths) = prepare_data(Data, Num_detections, Random_P, T)

    Random_partitions = deepcopy(Prepared_data)

    for t = 1:T
        Random_partitions[t][:] = shuffle(Random_partitions[t][:])
    end

    return Random_partitions, Random_P

end
