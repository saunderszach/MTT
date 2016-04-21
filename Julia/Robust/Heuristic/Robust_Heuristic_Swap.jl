#####################################
##     MTT HEURISTIC WITH SWAP     ##
#####################################
function robust_heuristic_swap(Data::Vector{Vector{Float64}}, 
                               Num_Detections::Array{Int64,1}, 
                               Lengths::Array{Int64,1}, 
                               P::Int64,
                               T::Int64,
                               θ::Float64,
                               ϕ::Float64)

################################################
### STEP 1: ASSIGN RANDOM INITIAL PARTITIONS ###
################################################
Partitions = deepcopy(Data)
for t = 1:T
  N = max(P, Num_Detections[t])                     ### Store the max of n(t) and P to N
  Partitions[t][1:N] = shuffle(Partitions[t][1:N])  ### Shuffle the elements 1:N in each time step
end

#################################################
### Step 2: CALCULATE INITIAL OBJECTIVE SCORE ###
#################################################
(Best_RSS, Best_Total_FA, Best_Total_MD) = calc_obj(P,T,Partitions, Lengths)
Best_Objective = sum(Best_RSS) + θ*Best_Total_FA + ϕ*Best_Total_MD

################################################################################
### STEP 3: SWEEEP THROUGH EACH TIME STEP AND SWAP UNTIL NO IMPROVEMENT MADE ###
################################################################################
stop = false;                      # Set stopping variable to false to initialize loop
Swap_Index = zeros(Int64, 2)       # Initialize swap index vector

while stop == false
  stop = true;
  for t = 2:T

    Swap_Index[1] = rand(1:P)
    Swap_Index[2] = rand(1:Lengths[t])

    while Swap_Index[1] == Swap_Index[2] || Partitions[t][Swap_Index[1]] == -1000 && Partitions[t][Swap_Index[2]] == -1000
      Swap_Index[1] = rand(1:P)
      Swap_Index[2] = rand(1:Lengths[t])
    end

      (New_RSS, New_Total_FA, New_Total_MD) = update_obj(Best_RSS, Best_Total_FA, Best_Total_MD, Swap_Index, Partitions, P, t, T)
      
      New_Objective = sum(New_RSS) + θ*New_Total_FA + ϕ*New_Total_MD

      if New_Objective < Best_Objective
        Best_Objective = New_Objective
        Best_RSS       = copy(New_RSS)
        Best_Total_FA  = New_Total_FA
        Best_Total_MD  = New_Total_MD

        # Make the switch
        Partitions[t][Swap_Index[1]], Partitions[t][Swap_Index[2]] = Partitions[t][Swap_Index[2]], Partitions[t][Swap_Index[1]]

        # Mark to continue switching
        stop = false;        
      end

  end
end

  return Best_Objective, Partitions

end
