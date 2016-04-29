function remove_detections(Data::Vector{Vector{Float64}}, 
						   P::Int64,
					   	   T::Int64,
				  	       γ::Float64)

	New_data = deepcopy(Data)
	Data_key = deepcopy(Data)

	for t = 1:T 

		stop = false

		while stop == false
			
			New_data[t] = deepcopy(Data[t])

			Num_removed = 0

			for i = 1:P

				if rand() > γ
					splice!(New_data[t], (i-Num_removed))
					Data_key[t][i] = -1000
					Num_removed = Num_removed + 1
				end

			end 

			if !isempty(New_data[t])
				stop = true 
			end

		end
	end

	return New_data, Data_key

end