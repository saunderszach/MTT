function simulate_perturbations(P::Int64,
                                T::Int64)

  ### SIMULATE (NORMALLY DISTRIBUTED) PERTURBATIONS OF THE TRUE POSITIONS ###
  Perturbations = Vector{Float64}[Float64[randn() for i in 1:P] for t in 1:T]

  return Perturbations

end #simulate_perturbations
