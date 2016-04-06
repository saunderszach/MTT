function remove_detections(Data::Vector{Vector{Float64}}, 
						   P::Int64,
					   	   T::Int64,
				  	       γ::Float64)

	New_data = deepcopy(Data)

	for t = 1:T 
		
		Num_removed = 0

		for i = 1:P

			if rand() > γ
				splice!(New_data[t], (i-Num_removed))
				Num_removed = Num_removed + 1
			end

		end 
	end

	return New_data

end