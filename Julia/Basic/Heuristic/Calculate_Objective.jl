######################################################
## Solves for the RSS of the provided partition set ##
######################################################

function calc_RSS(Partitions::Vector{Vector{Float64}}, P::Int64, T::Int64, M::Array{Float64,2})

  RSS = zeros(P)

  for p = 1:P

      Position = Float64[]

      for t = 1:T
        push!(Position,Partitions[t][p])
      end

      RSS[p] = (norm((Position')*M))^2
    end

  return RSS
end
