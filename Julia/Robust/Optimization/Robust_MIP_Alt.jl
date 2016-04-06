function run_robust_MIP(Data, Num_Detections, Big_M_1,P, T, Θ, ϕ)

Big_M_2 = 100

#Initialize optimization model
MIP = Model(solver=GurobiSolver(OutputFlag=0));

#Define model variables
@defVar(MIP, y[t=1:T,i=1:Num_Detections[t],j=1:N_1], Bin);
@defVar(MIP, z[j=1:N_1,t=1:T])
@defVar(MIP, α[j=1:N_1])
@defVar(MIP, abs_α[j=1:N_1])
@defVar(MIP, β[j=1:N_1])
@defVar(MIP, abs_β[j=1:N_1])
@defVar(MIP, ψ[j=1:N_1,t=1:T])
@defVar(MIP, F[t=1:T,i=1:Num_Detections[t]], Bin)
@defVar(MIP, M[j=1:N_1,t=1:T], Bin)
@defVar(MIP, w[j=1:N_1], Bin)
@defVar(MIP, TM, Int)
@defVar(MIP, TF, Int)

#Add assignment constraints: each detection gets assigned to an existing target
#                            OR it is designated as a False Alarm
for t = 1:T
    for i = 1:Num_Detections[t]
        @addConstraint(MIP, sum{y[t,i,j], j=1:N_1} + F[t,i] == 1);
  end
end

#Add assignment constraints: each existing target gets assigned a single detection
#                            OR it is designated as a Missed Detection
for t = 1:T
  for j = 1:N_1
        @addConstraint(MIP, sum{y[t,i,j], i=1:Num_Detections[t]} + M[j,t] == w[j]);
  end
end

#Add constraint: the sum of all False Alarms equals Total False Alarms (TF)
@addConstraint(MIP, sum{F[t,i], t=1:T,i=1:Num_Detections[t]} == TF)

#Add constraint: the sum of all Missed Detections equals Total Missed Detections (TM)
@addConstraint(MIP, sum{M[j,t], j=1:N_1,t=1:T} == TM)

#Add constraint: to sum of all existing targets must be between N_0 and N_1
@addConstraint(MIP, sum{w[j], j=1:N_1} <= N_1)
@addConstraint(MIP, sum{w[j], j=1:N_1} >= N_0)

#Add constraints: the α[j] and β[j] can only be nonzero if target j exists (w[j]=1)
for j=1:N_1
    @addConstraint(MIP, abs_α[j] + abs_β[j] <= Big_M_2*w[j])
    @addConstraint(MIP, α[j] <= abs_α[j])
    @addConstraint(MIP, β[j] <= abs_β[j])
    @addConstraint(MIP, α[j] >= -abs_α[j])
    @addConstraint(MIP, β[j] >= -abs_β[j])
end

#Add model constaints: z[j,t] = x[i,t] if detection i is assigned to trajectory j
for t = 1:T
  for i = 1:Num_Detections[t]
    for j = 1:N_1
        @addConstraint(MIP, Data[t][i]*y[t,i,j] + Big_M_1*(1-y[t,i,j]) >= z[j,t])
        @addConstraint(MIP, Data[t][i]*y[t,i,j] - Big_M_1*(1-y[t,i,j]) <= z[j,t])
    end
  end
end

#Add model constraints: Use θ[i,t] to replace absolute value in objective
for j=1:N_1
    for t=1:T
        @addConstraint(MIP,  (z[j,t] - α[j] - (t)*β[j]) - ψ[j,t] <= 0)
        @addConstraint(MIP, -(z[j,t] - α[j] - (t)*β[j]) - ψ[j,t] <= 0)
    end
end

#Add objective function to model
@setObjective(MIP, Min, sum{ψ[j,t], j=1:N_1, t=1:T} + θ*TF + ϕ*TM)


#################################################################
###    SET WARMSTART SOLUTION AND PREPARE TO SOLVE MODEL     ####
#################################################################
#=
Assignment_index = solve_traj_assignment(P,T, x, Heuristic_Partitions);

for i = 1:P
  for t = 1:T
    for j = 1:P
      if x[t][i] == Heuristic_Partitions[t][i]
        setValue(y[t,i,j], 1)
      else
        setValue(y[t,i,j], 0)
      end
    end
  end
end

####################################################
###    SOLVE MODEL AND STORE/ANALYZE RESULTS    ####
####################################################
=#
### SOLVE THE MIP ###
status = solve(MIP)
Num_Detections
N_1
T
### CAPTURE THE SOLUTION ###
y_values = zeros(Int64,N_1,T,N_1)

for t = 1:T
  for i = 1:Num_Detections[t]
    for j = 1:N_1
       y_values[i,t,j] =  convert(Int64,getValue(y[t,i,j]))
    end
  end
end

F_values = zeros(Int64,N_1,T)
for t = 1:T
    for i = 1:Num_Detections[t]
        F_values = convert(Int64,getValue(F[t,i]))
    end
end

M_values = getValue(M[:,:])
w_values = getValue(w[:])
Total_FA = getValue(TF)
Total_MD = getValue(TM)

### CALCULATE THE OBJECTIVE WITH RSS ###

Lengths = zeros(Int64,T)
for t = 1:T
  Num_Detections[t] = length(Data[t])
end

Optimized_Partitions = cell(T)
for t = 1:T
  Optimized_Partitions[t] = fill(-1000,Lengths[t])
  for i = 1:Num_Detections[t]
    for j = 1:N_1
      if y_values[i,t,j] == 1
          Optimized_Partitions[t][j] = Data[t][i]
      end
    end
  end
end

Data[1][1]

y_values

Objective_Value = getObjectiveValue(MIP)
w_values = getValue(w[:])
Est_Num_Targets = sum(w_values)

MIP_Objective = calc_objective(Est_Num_Targets,T,Optimized_Partitions, Lengths, θ, ϕ)

println(MIP_Objective)


    return Objective_Value, Est_Num_Targets
end
