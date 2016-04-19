###########################################################
## Solves for the accuracy of the provided partition set ##
###########################################################

function calc_accuracy(True_Partitions::Vector{Vector{Float64}},
                       Estimated_Partitions::Vector{Vector{Float64}},
                       Track_index::Array{Int64,1},
                       True_P::Int64,
                       Test_P::Int64,
                       T::Int64)

  Lengths = zeros(Int64,T)

  for t = 1:T
    Lengths[t] = length(True_Partitions[t])
  end

  Accuracy_matrix = Array(Vector{Int64},T)

  for t = 1:T
    Accuracy_matrix[t] = zeros(Int64, Lengths[t])
  end

  for t = 1:T
    for p = 1:Test_P
        
        if Track_index[p]!=0

          if Estimated_Partitions[t][p] == True_Partitions[t][Track_index[p]]
            Accuracy_matrix[t][Track_index[p]] = 1;
          end  

        end

    end

    for p = (Test_P+1):length(Estimated_Partitions[t])

      LengthTP = length(True_Partitions[t])

      if LengthTP >= (True_P+1) && Estimated_Partitions[t][p]!=-1000

        index = find(True_Partitions[t][True_P+1:LengthTP].==Estimated_Partitions[t][p])

        if !isempty(index)
          Accuracy_matrix[t][True_P + index[1]] = 1;
        end

      end
    end
  end

  Num_correct = 0
  for t = 1:T
    Num_correct = Num_correct + sum(Accuracy_matrix[t])
  end

  Accuracy = Num_correct/(sum(Lengths))

  return Accuracy

end
