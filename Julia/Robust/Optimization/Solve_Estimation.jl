function solve_estimation(Data::Vector{Vector{Float64}}, 
                          Estimated_partitions::Vector{Vector{Float64}},
                          Num_detections::Array{Int64,1},
                          Grid_size::Int64,
                          P::Int64, 
                          T::Int64,
                          Theta::Float64, 
                          Phi::Float64)

### RUN GARBAGE COLLECTOR ###
gc()

### Initialize optimization model
MIP = Model(solver=GurobiSolver(OutputFlag=0, Threads=1));

### Define model variables
@defVar(MIP, y[t=1:T,i=1:Num_detections[t],j=1:P], Bin);
@defVar(MIP, z[j=1:P,t=1:T])
@defVar(MIP, α[j=1:P])
@defVar(MIP, β[j=1:P])
@defVar(MIP, ψ[j=1:P,t=1:T])
@defVar(MIP, F[t=1:T,i=1:Num_detections[t]], Bin)
@defVar(MIP, M[j=1:P,t=1:T], Bin)
@defVar(MIP, TM)
@defVar(MIP, TF)

#Add assignment constraints: each detection gets assigned to an existing target
#                            OR it is designated as a False Alarm
for t = 1:T
  for i = 1:Num_detections[t]
    @addConstraint(MIP, sum{y[t,i,j], j=1:P} + F[t,i] == 1);
  end
end

#Add assignment constraints: each existing target gets assigned a single detection
#                            OR it is designated as a Missed Detection
for t = 1:T
  for j = 1:P
    @addConstraint(MIP, sum{y[t,i,j], i=1:Num_detections[t]} + M[j,t] == 1);
  end
end

### Add constraint: the sum of all False Alarms equals Total False Alarms (TF)
@addConstraint(MIP, sum{F[t,i], t=1:T,i=1:Num_detections[t]} == TF)

### Add constraint: the sum of all Missed Detections equals Total Missed Detections (TM)
@addConstraint(MIP, sum{M[j,t], j=1:P,t=1:T} == TM)

### PRESOLVE FOR SMART BIG_M VALUES ####
Big_M = zeros(T)
Big_M2 = zeros(T)
for t = 1:T
  Big_M[t]  = maximum(abs(Data[t]))
  Big_M2[t] = Grid_size - Big_M[t]
end

### Add model constaints: z[j,t] = x[i,t] if detection i is assigned to trajectory j
for t = 1:T
  for i = 1:Num_detections[t]
    for j = 1:P
      @addConstraint(MIP, Data[t][i]*y[t,i,j] + Big_M2[t]*M[j,t] + Big_M[t]*(1-y[t,i,j]) >= z[j,t])
      @addConstraint(MIP, Data[t][i]*y[t,i,j] - Big_M2[t]*M[j,t] - Big_M[t]*(1-y[t,i,j]) <= z[j,t])
    end
  end
end

### Add model constraints: Use θ[i,t] to replace absolute value in objective
for j = 1:P
  for t = 1:T
    @addConstraint(MIP,  (z[j,t] - α[j] - (t)*β[j]) - ψ[j,t] <= 0)
    @addConstraint(MIP, -(z[j,t] - α[j] - (t)*β[j]) - ψ[j,t] <= 0)
  end
end

### Add objective function to model
@setObjective(MIP, Min, sum{ψ[j,t], j=1:P, t=1:T} + Theta*TF + Phi*TM)

### ADD CONSTRAINTS TO RESTRICT TO THE CURRENT SOLUTION
Lengths = zeros(Int64, T)
for t = 1:T
  Lengths[t] = length(Estimated_partitions[t])
end

for t = 1:T
  for j = 1:P

    if Estimated_partitions[t][j] != -1000

      index = find(Data[t] .== Estimated_partitions[t][j])
      @addConstraint(MIP, y[t,index[1],j] == 1)

      for i = 1:Num_detections[t]
        if i != index[1]
          @addConstraint(MIP, y[t,i,j] == 0)  
        end
      end

      @addConstraint(MIP, M[j,t] == 0)
      @addConstraint(MIP, F[t,index[1]] == 0)
      
    else
      
      @addConstraint(MIP, M[j,t] == 1)

      for i = 1:Num_detections[t]
        @addConstraint(MIP, y[t,i,j] == 0)  
      end

    end
  end

  for j = (P+1):Lengths[t] 

    if Estimated_partitions[t][j] != -1000

      index = find(Data[t] .== Estimated_partitions[t][j])
      @addConstraint(MIP, F[t,index[1]] == 1)

      for k = 1:P
        @addConstraint(MIP, y[t,index[1],k] == 0)  
      end
      
    end

  end
end

### SOLVE THE MIP ###
status = solve(MIP)

### CAPTURE THE OBJECTIVE VALUE AND SOLUTION PARAMETERS ###
Objective_value = getObjectiveValue(MIP)
Alpha = getValue(α[:])
Beta = getValue(β[:])

### RUN GARBAGE COLLECTOR ###
gc()

    return Objective_value, Alpha, Beta
end
