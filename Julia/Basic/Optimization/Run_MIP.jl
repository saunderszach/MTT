type NodeData
    time::Float64  # in nanoseconds
    obj::Float64
    bestbound::Float64
end

function run_MIP(Data::Vector{Vector{Float64}},
                 Heuristic_partitions::Vector{Vector{Float64}},
                 Alpha::Array{Float64,1},
                 Beta::Array{Float64,1},
                 P::Int64,
                 T::Int64,
                 Write_path::ASCIIString,
                 Time_limit::Int64,
                 Random_seed::Int64,
                 Num_threads::Int64)

### INITIALIZE MODEL ###
MIP = Model(solver=GurobiSolver(OutputFlag=0, MIPFocus=1, Cuts=2, Presolve=2,
                                Threads   = Num_threads,
                                TimeLimit = Time_limit,
                                Seed      = Random_seed));

#DEFINE MODEL VARIABLES
@defVar(MIP, y[i=1:P,t=1:T,j=1:P], Bin);
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

### ADD MODEL CONSTRAINTS: Use θ[i,t] to replace absolute value in objective
for i=1:P
  for t=1:T
    for j=1:P
      @addConstraint(MIP,  (sum{Data[t][i]*y[i,t,j], i=1:P} - α[j] - (t)*β[j]) - θ[j,t] <= 0)
      @addConstraint(MIP, -(sum{Data[t][i]*y[i,t,j], i=1:P} - α[j] - (t)*β[j]) - θ[j,t] <= 0)
    end
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
bbdata    = NodeData[]
row_count = 1

function infocallback(cb)
  obj           = MathProgBase.cbgetobj(cb)
  bestbound     = MathProgBase.cbgetbestbound(cb)
  current_time  = time()

  if isempty(bbdata)
    push!(bbdata, NodeData(current_time - time_init,obj,bestbound))
  end

  if abs(obj-bbdata[row_count].obj)>0 || abs(bestbound-bbdata[row_count].bestbound)>0
    push!(bbdata, NodeData(current_time - time_init,obj,bestbound))
    row_count = row_count + 1
  end

end
addInfoCallback(MIP, infocallback)


####################################################
###    SOLVE MODEL AND STORE/ANALYZE RESULTS    ####
####################################################

### SAVE THE INITIALIZED TIME ###
time_init = time()

### SOLVE THE MIP ###
Status = solve(MIP)

### STORE THE SOLUTION ###
Objective_value = getObjectiveValue(MIP)
y_values        = round(getValue(y[:,:,:]))

Best_Bound = MathProgBase.getobjbound(getInternalModel(MIP))
Solve_time = MathProgBase.getsolvetime(getInternalModel(MIP))

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
    println(fp,Solve_time, ",", Objective_value, ",", Best_Bound)
end

    return Objective_value, Optimized_partitions

end

