function run_precompiler()

	P = 2
	T = 2
	N = 5
	Data = Array(Vector{Float64},T)
	Data[1] = [1,2]
	Data[2] = [3,4]

	Time_limit  = 1
	MIP_seed    = 1
	Num_threads = 1

	### RUN GARBAGE COLLECTOR ###
    gc()

	### PRECOMPUTE DESIGN MATRIX ###
	X      = ones(T, 2);
	X[:,2] = 1:T;
	M      = eye(T)-X*inv(X'X)*X';

	### PRECOMPILE HEURISTIC ###
	(Heuristic_partitions) = run_heuristic(Data, P, T, N, M)

	### PRECOMPILE PRESOLVER ###
	(Heuristic_abs_obj, Alpha, Beta) = solve_estimation(Data, Heuristic_partitions , P, T)

	### PRECOMPILE MIP ###
	MIP_write_path = string(Path_stem, "Experiment/Garbage/Output.csv")
	(Optimized_abs_obj, Optimized_partitions) = run_MIP(Data, Heuristic_partitions, Alpha, Beta, P, T, MIP_write_path, Time_limit, MIP_seed, Num_threads)

end #run_precompiler