function calc_density(True_Trajectory::Vector{Vector{Float64}},
                      P::Int64,
                      T::Int64,
                      σ::Float64)

  Point_distance = Float64[abs(True_Trajectory[t][i] - True_Trajectory[t][j]) for i=1:P, j=1:P, t=1:T]

  # Distance = 1e9*ones(P,P)

  # for i=1:P
  #   for j=i+1:P
  #     Distance[i,j] = 0;
  #     for t=1:T
  #         Distance[i,j] = Distance[i,j] + Point_distance[i,j,t]
  #     end
  #   end
  # end

  # Min_distance = zeros(P)
  # for i = 1:P
  #   Temp = vcat(vec(Distance[i,:]),vec(Distance[:,i]))
  #   Min_distance[i] = minimum(Temp)
  # end

  # Temp2 = vec(Distance)
  # Temp2 = Temp2[Temp2.<1e9]
  # Sort_distance = sort(Temp2)

  # α = .20
  # Num_grab = convert(Int64,floor(binomial(P,2)*α))

  # if Num_grab == 0
  #   Num_grab = 1
  # end

  # α_min_distance = Sort_distance[Num_grab]

  Accuracy_count = 0
  for t=1:T 
      for i=1:P
        for j=i+1:P
          if Point_distance[i,j,t] > 2*σ
            Accuracy_count = Accuracy_count + 1;
          end
        end
      end
  end

  #ρ  = sum(Temp2)/(binomial(P,2)*T*σ)
  #ρ2 = sum(Min_distance)/(P*T*σ)
  #ρ3 = α_min_distance/(T*σ)
  ρ4 = Accuracy_count/(binomial(P,2)*T)

    return ρ4
end

