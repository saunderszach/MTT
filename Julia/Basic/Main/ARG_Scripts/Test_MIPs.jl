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

const P  = parse(Int, ARGS[1])         # Number of targets
const T  = parse(Int, ARGS[2])         # Number of time steps
 
const Scenario_num   = parse(Int, ARGS[3])       # Scenario number
const Sim_num        = parse(Int, ARGS[4])       # Simulation number

const σ = parse(Float64, ARGS[5])        # Noise parameter
const N = parse(Int, ARGS[6])          # Number of heuristic starting points

const MIP_time_limit     = 300         # Maximum allowed run time (in seconds)
const MIP_solution_limit = 30          # Maximum number of solutions allowed


#######################################################
###    STEP 4: RUN EXPERIMENT ON SIMULATED DATA    ####
#######################################################

### CREATE REQUIRED DIRECTORIES ###
mypath = string(Path_stem, "Experiment/Simulation_Summaries")
isdir(mypath) || mkdir(mypath)

mypath = string(Path_stem, "Experiment/MIP_Summaries")
isdir(mypath) || mkdir(mypath)

mypath = string(Path_stem, "Experiment/Heuristic_Solutions")
isdir(mypath) || mkdir(mypath)

mypath = string(Path_stem, "Experiment/MIP_Solutions")
isdir(mypath) || mkdir(mypath)

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




