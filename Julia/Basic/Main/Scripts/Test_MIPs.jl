using Gurobi, JuMP

#### CHANGE TO LOCAL GIT DIRECTORY ###
const Path_stem = "/Users/za25454/Documents/Academic/Research/Git/Multi-Target-Tracking/Julia/Basic/"

### LOAD REQUIRED FUNCTIONS/SCRIPTS ###
include(string(Path_stem, "Functions/Miscellaneous/Read_Partitions.jl"))
include(string(Path_stem, "Functions/Miscellaneous/Write_Partitions.jl"))
include(string(Path_stem, "Functions/Miscellaneous/Run_Precompiler.jl"))

include(string(Path_stem, "Heuristic/Calculate_Objective.jl"))
include(string(Path_stem, "Heuristic/Update_Objective.jl"))
include(string(Path_stem, "Heuristic/Heuristic_Swap.jl"))
include(string(Path_stem, "Heuristic/Run_Heuristic.jl"))

include(string(Path_stem, "Optimization/Solve_Estimation.jl"))
include(string(Path_stem, "Optimization/Run_MIP.jl"))
include(string(Path_stem, "Optimization/Run_MIP_Alt.jl"))


#####################################################
###    STEP 0: DEFINE EXPERIMENTAL PARAMETERS    ####
#####################################################

const P             		= 10 
const T             		= 10
const Scenario_num 			= 1
const Sim_num				= 1
const σ              		= 0.1 
const N               		= 1000
const MIP_time_limit     	= 500  
const MIP_solution_limit 	= 500 

#######################################################
###    STEP 4: RUN EXPERIMENT ON SIMULATED DATA    ####
#######################################################

### PRECOMPILE CODE TO ELIMINATE GARBAGE TIME ###
#run_precompiler()

### PRECOMPUTE DESIGN MATRIX ###
X      = ones(T, 2);
X[:,2] = 1:T;
M      = eye(T)-X*inv(X'X)*X';

### READ IN DATA FOR SIMULATION ###
Read_path = string(Path_stem, "Experiment/Data/", string(P), "_", string(T), "_", string(Scenario_num), "_", string(Sim_num), "_", string(σ), ".csv")
Data      = read_partitions(Read_path, T)

### PRINT PROGRESS TO SCREEN ###
println("P:", P, " T:", T, " Sce num:", Scenario_num, " Sim num:", Sim_num, " Sigma:", σ, " N:", N)

### SET THE SEED  ###
srand(convert(Int64, P + T*10 + Scenario_num*100 + Sim_num*1000 + σ*10000 + N*100000))

### RUN AND TIME HEURISTIC ###
(Heuristic_partitions) = run_heuristic(Data, P, T, N, M)


### ESTIMATE PARAMETERS OF HEURISTIC SOLUTION ###
(Heuristic_abs_obj, Alpha, Beta) = solve_estimation(Data, Heuristic_partitions , P, T)

### Run original MIO ###
MIP_write_path = string(Path_stem, "Experiment/MIP_Summaries/", string(P), "_", string(T), "_", string(Scenario_num), "_", string(Sim_num), "_", string(σ), "_", string(N), "_original.csv")
(Optimized_abs_obj, Optimized_partitions) = run_MIP(Data, Heuristic_partitions, Alpha, Beta, P, T, MIP_write_path, MIP_time_limit, MIP_solution_limit)


### Run New MIO ###
MIP_write_path = string(Path_stem, "Experiment/MIP_Summaries/", string(P), "_", string(T), "_", string(Scenario_num), "_", string(Sim_num), "_", string(σ), "_", string(N), "_alternate.csv")
(Optimized_abs_obj, Optimized_partitions) = run_alt_MIP(Data, Heuristic_partitions, Alpha, Beta, P, T, MIP_write_path, MIP_time_limit, MIP_solution_limit)


