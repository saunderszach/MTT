###########################################################
## Solves for the accuracy of the provided partition set ##
###########################################################

function calc_accuracy(True_Partitions::Vector{Vector{Float64}},
                       Estimated_Partitions::Vector{Vector{Float64}},
                       Track_index::Array{Int64,1},
                       P::Int64,
                       T::Int64)

  Accuracy_matrix = zeros(Int64, P, T)

  for t = 1:T
    for p = 1:P
      if Estimated_Partitions[t][p] == True_Partitions[t][Track_index[p]]
        Accuracy_matrix[p,t] = 1;
      end
    end
  end

  Accuracy = sum(Accuracy_matrix)/(P*T)

  return Accuracy

end
