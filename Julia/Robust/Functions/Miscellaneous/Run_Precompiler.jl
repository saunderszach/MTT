function run_precompiler()

	P = 2
	T = 2
	N = 5
	θ = 1.0
	ϕ = 1.0
	Grid_size = 5

	Data = Array(Vector{Float64},T)
	Data[1] = [1, 4, 8]
	Data[2] = [-1, 5]

	Num_detections = zeros(Int64, T)
	for t = 1:T
        Num_detections[t] = length(Data[t])
    end

	(Test_data, Lengths) = prepare_data(Data, Num_detections, P, T)

	Time_limit  = 1
	MIP_seed    = 1
	Num_threads = 1

	### PRECOMPUTE DESIGN MATRIX ###
	X      = ones(T, 2);
	X[:,2] = 1:T;
	M      = eye(T)-X*inv(X'X)*X';

	### PRECOMPILE HEURISTIC ###
	(Heuristic_partitions) = run_robust_heuristic(Test_data, Num_detections, Lengths, N, P, T, θ, ϕ)

	 ### RUN GARBAGE COLLECTOR ###
  	gc()

	### PRECOMPILE PRESOLVER ###
	(Heuristic_abs_obj, Alpha, Beta) = solve_estimation(Data, Heuristic_partitions, Num_detections, Grid_size, P, T, θ, ϕ)

	### RUN GARBAGE COLLECTOR ###
  	gc()

	### PRECOMPILE MIP ###
	MIP_write_path = string(Path_stem, "Experiment/Garbage/Output.csv")
	(Optimized_abs_obj, Optimized_partitions) = run_robust_MIP(Data, Heuristic_partitions, Num_detections, Alpha, Beta, Grid_size, P, T, θ, ϕ, MIP_write_path, Time_limit, MIP_seed, Num_threads)

	### RUN GARBAGE COLLECTOR ###
  	gc()

end #run_precompiler