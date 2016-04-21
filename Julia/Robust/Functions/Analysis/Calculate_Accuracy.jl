###########################################################
## Solves for the accuracy of the provided partition set ##
###########################################################

function calc_accuracy(Data_key::Vector{Vector{Float64}},
                       Estimated_Partitions::Vector{Vector{Float64}},
                       Track_index::Array{Int64,1},
                       True_P::Int64,
                       Test_P::Int64,
                       T::Int64)

  Lengths = zeros(Int64,T)

  for t = 1:T
    Lengths[t] = length(Data_key[t])
  end

  Accuracy_key = Array(Vector{Int64},T)

  for t = 1:T
    Accuracy_key[t] = zeros(Int64, Lengths[t])
  end

  for t = 1:T
    for p = 1:Test_P
        
        if Track_index[p]!=0

          if Estimated_Partitions[t][p] == Data_key[t][Track_index[p]]
            Accuracy_key[t][Track_index[p]] = 1;
          end  

        end

    end

    for p = (Test_P+1):length(Estimated_Partitions[t])

      LengthTP = length(Data_key[t])

      if LengthTP >= (True_P+1) && Estimated_Partitions[t][p]!=-1000

        index = find(Data_key[t][True_P+1:LengthTP].==Estimated_Partitions[t][p])

        if !isempty(index)
          Accuracy_key[t][True_P + index[1]] = 1;
        end

      end
    end
  end

  Num_correct = zeros(Int64,T)
  for t = 1:T
    Num_correct[t] = sum(Accuracy_key[t])
  end

  Accuracy = sum(Num_correct)/sum(Lengths)

  return Accuracy

end
