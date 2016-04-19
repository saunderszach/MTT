function estimate_positions(Alpha::Vector{Float64},
                            Beta::Vector{Float64},
                            P::Int64,
                            T::Int64)


  Estimated_positions = Vector{Float64}[Float64[Alpha[i] + Beta[i]*(t) for i in 1:P] for t in 1:T]

  return Estimated_positions

end

