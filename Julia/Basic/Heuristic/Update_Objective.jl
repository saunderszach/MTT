######################################################
## Solves for the RSS of the provided partition set ##
######################################################

function update_RSS(RSS::Array{Float64,1},
                    Swap_Index::Array{Int64,1},
                    Partitions::Vector{Vector{Float64}},
                    T::Int64,
                    M::Array{Float64,2})

  New_RSS = copy(RSS)

  for p in Swap_Index

      Position = Float64[]

      for t = 1:T
        push!(Position,Partitions[t][p])
      end

      New_RSS[p] = (norm((Position')*M))^2
  end

  return New_RSS
end
