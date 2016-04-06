function assemble_detections(True_Position::Array{Array{Float64,1},1},
                             P::Int64,
                             T::Int64,
                             σ::Float64)

	Distribution = Normal(0, σ)

  	Detections = Vector{Float64}[Float64[True_Position[t][i] + rand(Distribution) for i in 1:P] for t in 1:T]

  	return Detections

end #assemble_detections


