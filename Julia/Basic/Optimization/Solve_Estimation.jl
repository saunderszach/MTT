function solve_estimation(Data::Vector{Vector{Float64}},
                          Estimated_Partitions::Vector{Vector{Float64}},
                          P::Int64,
                          T::Int64)

#Initialize optimization model
MIP = Model(solver=GurobiSolver(OutputFlag=0, Threads = 1));

### DEFINE MODEL VARIABLES
@defVar(MIP, y[i=1:P,t=1:T,j=1:P], Bin);
@defVar(MIP, z[j=1:P,t=1:T])
@defVar(MIP, α[j=1:P])
@defVar(MIP, β[j=1:P])
@defVar(MIP, θ[j=1:P,t=1:T])

### ADD MODEL CONSTRAINTS: each detection gets assigned to a single partition
for i = 1:P
  for t = 1:T
        @addConstraint(MIP, sum{y[i,t,j], j=1:P} == 1);
  end
end

### ADD MODEL CONSTRAINTS: each partition gets assigned a single detection
for t = 1:T
    for j = 1:P
        @addConstraint(MIP, sum{y[i,t,j], i=1:P} == 1);
  end
end

### PRESOLVE FOR SMART BIG_M VALUES ####
Big_M = zeros(T)
for t = 1:T
  Big_M[t] = maximum(abs(Data[t]))
end

### ADD MODEL CONSTRAINTS: z[j,t] = Data[t][i] if detection i is assigned to trajectory j
for i = 1:P
  for t = 1:T
    for j = 1:P
        @addConstraint(MIP, Data[t][i]*y[i,t,j] + Big_M[t]*(1-y[i,t,j]) >= z[j,t])
        @addConstraint(MIP, Data[t][i]*y[i,t,j] - Big_M[t]*(1-y[i,t,j]) <= z[j,t])
    end
  end
end

### ADD MODEL CONSTRAINTS: Use θ[i,t] to replace absolute value in objective
for j=1:P
    for t=1:T
        @addConstraint(MIP,  (z[j,t] - α[j] - (t)*β[j]) - θ[j,t] <= 0)
        @addConstraint(MIP, -(z[j,t] - α[j] - (t)*β[j]) - θ[j,t] <= 0)
    end
end

### ADD THE OBJECTIVE FUNCTION
@setObjective(MIP, Min, sum{θ[j,t], j=1:P, t=1:T})

### ADD CONSTRAINTS TO RESTRICT TO THE CURRENT SOLUTION
for i = 1:P
  for t = 1:T
    for j = 1:P
      if Data[t][i] == Estimated_Partitions[t][j]
        @addConstraint(MIP, y[i,t,j] == 1)
      else
        @addConstraint(MIP, y[i,t,j] == 0)
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

  return Objective_value, Alpha, Beta

end
