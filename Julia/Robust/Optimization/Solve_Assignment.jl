##########################################
## Solves for the index of trajectories ##
##########################################

function solve_traj_assignment(True_Position::Vector{Vector{Float64}},
                               Estimated_Position::Vector{Vector{Float64}},
                               P::Int64,
                               T::Int64)

#TAM = Trajectory Assignment Model

TAM = Model(solver=GurobiSolver(OutputFlag=0, Threads = 1));

@defVar(TAM, y[i=1:P,j=1:P], Bin);

temp_cost = zeros(P,P,T)
cost = zeros(P,P)

for i = 1:P
  for j = 1:P
    for t = 1:T
        temp_cost[i,j,t] = abs(True_Position[t][j]-Estimated_Position[t][i])
        cost[i,j] = cost[i,j] + temp_cost[i,j,t]
    end
  end
end

@setObjective(TAM, Min, sum{cost[i,j]*y[i,j], i=1:P,j=1:P})

for i = 1:P
    @addConstraint(TAM, sum{y[i,j], j=1:P} == 1);
end

for j = 1:P
    @addConstraint(TAM, sum{y[i,j], i=1:P} == 1);
end

status = solve(TAM)

Track_assignments = zeros(Int,P)
y = getValue(y)

for i = 1:P
  for j = 1:P
    if y[i,j] == 1
      Track_assignments[i] = j
    end
  end
end

  return Track_assignments

end
