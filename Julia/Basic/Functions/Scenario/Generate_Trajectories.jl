function generate_trajectories(P::Int64,
                               T::Int64,
                               Grid_size::Int64,
                               Grid_steps::Int64,
                               Gap_size::Float64,
                               Level::ASCIIString)
  if Level == "Crossing"

    ### CREATE SEQUENCES OF POSSIBLE START/STOP POINTS
    Left_sequence  = linspace(-Grid_size, Grid_size, Grid_steps);
    Right_sequence = linspace(-Grid_size, Grid_size, Grid_steps);

    ### GENERATE VECTORS OF RANDOM INDICES
    Left_index  = rand(1:Grid_steps, P);
    Right_index = rand(1:Grid_steps, P);

    ### EXTRACT START/STOP POINTS FOR EACH TARGET
    Left  = Float64[Left_sequence[Left_index[i]]   for i in 1:P]
    Right = Float64[Right_sequence[Right_index[i]] for i in 1:P]

    ### CALCULATE VELOCITY FOR EACH TARGET
    Velocity = Float64[(Right[i] - Left[i])/T for i in 1:P]

    ### CALCULATE TRUE POSITION OF EACH TARGET
    True_position = Vector{Float64}[Float64[Left[i] + Velocity[i]*(t) for i in 1:P] for t in 1:T]

  elseif Level == "Parallel"

    Left     = zeros(P)
    Right    = zeros(P)
    Velocity = zeros(P)

    Num_gaps = P-1;
    Division_size = ((2*Grid_size) - (Num_gaps * Gap_size))/P

    for i = 1:P

      ### CREATE SEQUENCES OF POSSIBLE START/STOP POINTS
      Left_sequence  = linspace(-Grid_size + (Gap_size+Division_size)*(i-1), -Grid_size + Gap_size*(i-1) + Division_size*(i), Grid_steps);
      Right_sequence = linspace(-Grid_size + (Gap_size+Division_size)*(i-1), -Grid_size + Gap_size*(i-1) + Division_size*(i), Grid_steps);

      ### GENERATE RANDOM INDICES
      Left_index  = rand(1:Grid_steps);
      Right_index = rand(1:Grid_steps);

      ### EXTRACT START/STOP POINTS FOR EACH TARGET
      Left[i]  = Left_sequence[Left_index]
      Right[i] = Right_sequence[Right_index]

      ### CALCULATE VELOCITY FOR EACH TARGET
      Velocity[i] = (Right[i] - Left[i])/T

    end

    ### CALCULATE TRUE POSITION OF EACH TARGET
    True_position = Vector{Float64}[Float64[Left[i] + Velocity[i]*(t) for i in 1:P] for t in 1:T]

  else 
    println("ERROR: Please enter Easy or Hard for scenario type")
  end

  return True_position

end #generate_trajectories
