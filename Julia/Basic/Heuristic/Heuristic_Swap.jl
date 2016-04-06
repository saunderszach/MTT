#####################################
##     MTT HEURISTIC WITH SWAP     ##
#####################################
function heuristic_swap(Data::Vector{Vector{Float64}},
                        P::Int64,
                        T::Int64,
                        M::Array{Float64,2})

  ################################################
  ### STEP 1: ASSIGN RANDOM INITIAL PARTITIONS ###
  ################################################
  Partitions = deepcopy(Data)
  for t = 1:T
    Partitions[t][:] = shuffle(Partitions[t][:])
  end

  #####################################
  ### Step 2: CALCULATE INITIAL RSS ###
  #####################################
  Best_RSS = calc_RSS(Partitions, P, T, M)
  Best_Objective = sum(Best_RSS)

  ################################################################################
  ### STEP 3: SWEEEP THROUGH EACH TIME STEP AND SWAP UNTIL NO IMPROVEMENT MADE ###
  ################################################################################
  stop = false;                      # Set stopping variable to false to initialize loop
  Swap_Index = zeros(Int64, P)       # Initialize swap index vector

  while stop == false
    stop = true;
    for t = 2:T

      Swap_Index = shuffle(collect(1:P))

      while Swap_Index[1] == Swap_Index[2]
         Swap_Index = shuffle(collect(1:P))
      end

      Partitions[t][Swap_Index[1]], Partitions[t][Swap_Index[2]] = Partitions[t][Swap_Index[2]], Partitions[t][Swap_Index[1]]

      New_RSS = update_RSS(Best_RSS, Swap_Index, Partitions, T, M)
      New_Objective = sum(New_RSS)

      if New_Objective < Best_Objective
        Best_Objective = New_Objective
        Best_RSS = copy(New_RSS)
        stop = false
      else
        Partitions[t][Swap_Index[1]], Partitions[t][Swap_Index[2]] = Partitions[t][Swap_Index[2]], Partitions[t][Swap_Index[1]]
      end

    end
  end

  return Best_Objective, Partitions

end
