using Distributions, JuMP, Gurobi

#### CHANGE TO LOCAL GIT DIRECTORY ###
Path_stem = "/Users/za25454/Documents/Academic/Research/Git/Multi-Target-Tracking/"

### LOAD FUNCTIONS/SCRIPTS ###
include(string(Path_stem, "Julia/Functions/Calculate_Initial_Objective_Parameters.jl"))
include(string(Path_stem, "Julia/Functions/Update_Objective_Parameters.jl"))
include(string(Path_stem, "Julia/Heuristic/Functions/Robust/Robust_Heuristic_Swap_1.jl"))

P = 2
T = 3
Data = cell(T)
Data[1] = collect([1.1 3.2])
Data[2] = collect([2.0 2.1])
Data[3] = collect([3.3 1.3])
Data
Num_Detections = zeros(Int64,T)
Lengths = zeros(Int64,T)

for t = 1:T
  Num_Detections[t] = length(Data[t])
end

for t = 1:T
  for i = 1:Num_Detections[t]
    push!(Data[t],-1000)
  end

  while length(Data[t]) < P
      push!(Data[t],-1000)
  end
end

for t = 1:T
  Lengths[t] = length(Data[t])
end

Data
Lengths

Total_FA = 0    #Set the total # of False Alarms to zero
Total_MD = 0    #Set the total # of Missed Detections to zero

for t = 1:T                  #Loop through each time step
  for j = 1:Lengths[t]       #Loop through each detection in the time step

    if Data[t][j] == -1000
      if j <= P
        Total_MD = Total_MD + 1
      end
    else
      if j > P
        Total_FA = Total_FA + 1
      end

    end
  end
end

Total_FA
Total_MD

RSS = zeros(P)
for p=1:2
  count = 1
  Time = Int64[]
  Position = Float64[]

  for t = 1:T
    if Data[t][p] != -1000
      push!(Time,count)
      push!(Position,Data[t][p])
    end
    count = count + 1
  end
  Time
  Position

  Temp_T   = length(Time)

  X        = ones(Temp_T, 2);
  X[:,2]   = collect(Time);
  M        = eye(Temp_T)-X*((X'X)\(X'));
  #M        = eye(Temp_T)-X*inv(X'X)*X'

  RSS[p] = (norm((Position')*M))^2
end
RSS


calc_init_obj_param(P,T,Data, Lengths)

