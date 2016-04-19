##########################################
## Solves for the index of trajectories ##
##########################################

function solve_traj_assignment(True_Position::Vector{Vector{Float64}},
                               Estimated_Position::Vector{Vector{Float64}},
                               True_P::Int64,
                               Test_P::Int64,
                               T::Int64)

#TAM = Trajectory Assignment Model

TAM = Model(solver=GurobiSolver(OutputFlag=0, Threads = 1));

@defVar(TAM, y[i=1:Test_P,j=1:True_P], Bin);

temp_cost = zeros(Test_P,True_P,T)
cost = zeros(Test_P,True_P)

for i = 1:Test_P
  for j = 1:True_P
    for t = 1:T
        temp_cost[i,j,t] = abs(True_Position[t][j]-Estimated_Position[t][i])
        cost[i,j] = cost[i,j] + temp_cost[i,j,t]
    end
  end
end

@setObjective(TAM, Min, sum{cost[i,j]*y[i,j], i=1:Test_P,j=1:True_P})

if Test_P == True_P

  for i = 1:Test_P
      @addConstraint(TAM, sum{y[i,j], j=1:True_P} == 1);
  end

  for j = 1:True_P
      @addConstraint(TAM, sum{y[i,j], i=1:Test_P} == 1);
  end

elseif Test_P < True_P

  for i = 1:Test_P
      @addConstraint(TAM, sum{y[i,j], j=1:True_P} == 1);
  end

  for j = 1:True_P
      @addConstraint(TAM, sum{y[i,j], i=1:Test_P} <= 1);
  end

else # Test_P > True_P

  for i = 1:Test_P
      @addConstraint(TAM, sum{y[i,j], j=1:True_P} <= 1);
  end

  for j = 1:True_P
      @addConstraint(TAM, sum{y[i,j], i=1:Test_P} == 1);
  end

end

status = solve(TAM)

Track_assignments = zeros(Int,Test_P)
y = getValue(y)

for i = 1:Test_P
  for j = 1:True_P
    if y[i,j] == 1
      Track_assignments[i] = j
    end
  end
end

  return Track_assignments

end
