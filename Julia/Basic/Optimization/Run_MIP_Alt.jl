type NodeData
    time::Int64  # in nanoseconds
    obj::Float64
    bestbound::Float64
end

function run_alt_MIP(Data::Vector{Vector{Float64}},
                 Heuristic_partitions::Vector{Vector{Float64}},
                 Alpha::Array{Float64,1},
                 Beta::Array{Float64,1},
                 P::Int64,
                 T::Int64,
                 Write_path::ASCIIString,
                 Time_limit::Int64,
                 Solution_limit::Int64)

### INITIALIZE MODEL ###
MIP = Model(solver=GurobiSolver(OutputFlag=1, MIPFocus=1, Cuts=2, Presolve=2,
                                Threads = 1,
                                TimeLimit = Time_limit,
                                SolutionLimit = Solution_limit));

#DEFINE MODEL VARIABLES
@defVar(MIP, y[i=1:P,t=1:T,j=1:P], Bin);
@defVar(MIP, z[j=1:P,t=1:T])
@defVar(MIP, α[j=1:P])
@defVar(MIP, β[j=1:P])
@defVar(MIP, θ[j=1:P,t=1:T])

### ADD ASSIGNMENT CONSTRAINTS: each detection gets assigned to a single partition
for i = 1:P
  for t = 1:T
        @addConstraint(MIP, sum{y[i,t,j], j=1:P} == 1);
  end
end

### ADD ASSIGNMENT CONSTRAINTS: each partition gets assigned a single detection
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

### ADD OBJECTIVE FUNCTION TO MODEL ###
@setObjective(MIP, Min, sum{θ[j,t], j=1:P, t=1:T})

#################################################################
###    SET WARMSTART SOLUTION AND PREPARE TO SOLVE MODEL     ####
#################################################################

for i = 1:P
  for t = 1:T
    for j = 1:P
      if Data[t][i] == Heuristic_partitions[t][j]
          if t == 1
             @addConstraint(MIP, y[i,t,j] == 1)
          else
            setValue(y[i,t,j], 1)
          end
      else
          if t == 1
             @addConstraint(MIP, y[i,t,j] == 0)
          else
            setValue(y[i,t,j], 0)
          end
      end
    end
  end
end

for p = 1:P
  setValue(α[p], Alpha[p])
  setValue(β[p], Beta[p])
end


#########################################################################
###    SET CALLBACK FUNCTION TO CAPTURE MODEL PERFORMANCE METRICS    ####
#########################################################################

### ONLY COLLECT NODE DATA IF OBJECTIVE OR BOUND CHANGES ###
bbdata   = NodeData[]
count = 1

function infocallback(cb)
    obj       = MathProgBase.cbgetobj(cb)
    bestbound = MathProgBase.cbgetbestbound(cb)
    time      = MathProgBase.cbget_runtime(cb)

    if isempty(bbdata)
        push!(bbdata, NodeData(time,obj,bestbound))
    end

    if abs(obj-bbdata[count].obj)>0 || abs(bestbound-bbdata[count].bestbound)>0
      push!(bbdata, NodeData(time,obj,bestbound))
      count = count + 1
    end
end
addInfoCallback(MIP, infocallback)

#=
### COLLECT NODE DATA EVERY TIME ###
bbdata = NodeData[]
function infocallback(cb)
    obj       = MathProgBase.cbgetobj(cb)
    bestbound = MathProgBase.cbgetbestbound(cb)
    push!(bbdata, NodeData(time_ns(),obj,bestbound))
end
addInfoCallback(MIP, infocallback)
=#

####################################################
###    SOLVE MODEL AND STORE/ANALYZE RESULTS    ####
####################################################

### SOLVE THE MIP ###
status = solve(MIP)

### STORE THE SOLUTION ###
Objective_value = getObjectiveValue(MIP)
y_values = round(getValue(y[:,:,:]))

### FIND THE INDEX VECTOR OF ASSIGNMENTS ###
Assignment_index = zeros(Int,P,T);
for i = 1:P
    for t = 1:T
        for j = 1:P
            if y_values[i,t,j] == 1.0
              Assignment_index[i,t] = j;
            end
        end
    end
end

### CONSTRUCT THE OPTIMIZED PARTITION SET ###
Solution_partitions = zeros(P,T)
for i = 1:P
    for t = 1:T
      Solution_partitions[Assignment_index[i,t],t] = Data[t][i]
    end
end

Optimized_partitions = Array(Vector{Float64},T)
for t = 1:T
  Optimized_partitions[t] = Solution_partitions[:,t]
end

### WRITE THE MODEL PERFORMANCE DATA TO A FILE ###
open(Write_path,"w") do fp
    println(fp, "time,objective,bestbound")
    for bb in bbdata
        println(fp, bb.time, ",", bb.obj, ",", bb.bestbound)
    end
end

    return Objective_value, Optimized_partitions

end

