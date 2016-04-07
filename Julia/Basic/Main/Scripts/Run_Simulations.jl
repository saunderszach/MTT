using Gurobi, JuMP

#### CHANGE TO LOCAL GIT DIRECTORY ###
const Path_stem = "/Users/za25454/Documents/Academic/Research/Git/Multi-Target-Tracking/Julia/Basic/"

### LOAD REQUIRED FUNCTIONS/SCRIPTS ###
include(string(Path_stem, "Functions/Miscellaneous/Write_Partitions.jl"))
include(string(Path_stem, "Functions/Miscellaneous/Read_Partitions.jl"))
include(string(Path_stem, "Functions/Miscellaneous/Run_Precompiler.jl"))
include(string(Path_stem, "Functions/Miscellaneous/Create_Exp_Directories.jl"))

include(string(Path_stem, "Heuristic/Calculate_Objective.jl"))
include(string(Path_stem, "Heuristic/Update_Objective.jl"))
include(string(Path_stem, "Heuristic/Heuristic_Swap.jl"))
include(string(Path_stem, "Heuristic/Run_Heuristic.jl"))

include(string(Path_stem, "Optimization/Solve_Estimation.jl"))
include(string(Path_stem, "Optimization/Run_MIP.jl"))


#####################################################
###    STEP 0: DEFINE EXPERIMENTAL PARAMETERS    ####
#####################################################

const P_min             = 4                 # Minimum of target range
const P_step            = 2                 # Step size of target range
const P_max             = 10                # Maximum of target range

const T_min             = 4                 # Minimum of time range
const T_step            = 2                 # Step size of time range
const T_max             = 10                # Maximum of time range

const Scenario_min      = 1                 # Starting range of scenario numbers
const Scenario_max      = 20                # Ending range of scenario numbers

const σ_1               = 0.1               # 1st noise parameter value
const σ_2               = 0.5               # 2nd noise parameter value
const σ_3               = 1.0               # 3rd noise parameter value
const σ_4               = 2.0               # 4th noise parameter value
const σ_5               = 3.5               # 4th noise parameter value
const σ_6               = 5.0               # 4th noise parameter value

const Sim_min           = 1                 # Starting range of simulations
const Sim_max           = 10                # Ending range of simulations

const N_1               = 100               # 1st N to run heuristic 
const N_2               = 1000              # 2nd N to run heuristic 
const N_3               = 10000             # 3rd N to run heuristic 

const MIP_seed          = 5271992           # Set gurobi seed
const Num_threads       = 1                 # Set gurobi thread limit

### CONSTRUCT RANGES ###
P_range         = collect(P_min:P_step:P_max)            # Range of targets 
T_range         = collect(T_min:T_step:T_max)            # Range of time steps
Scenario_range  = collect(Scenario_min:1:Scenario_max)   # Range of scenarios
σ_range         = Float64[σ_1, σ_2, σ_3, σ_4, σ_5, σ_6]  # Range of noise parameters
Sim_range       = collect(Sim_min:1:Sim_max)             # Range of simulations
N_range         = Int64[N_1, N_2, N_3]                   # Range of heuristic starting points

### CREATE REQUIRED DIRECTORIES ###
create_directories(Path_stem, P_range, T_range)

#######################################################
###    STEP 4: RUN EXPERIMENT ON SIMULATED DATA    ####
#######################################################

### PRECOMPILE CODE TO ELIMINATE GARBAGE TIME ###
run_precompiler()

for P in P_range  
  for T in T_range

    ### Define range of times to run MIP
    MIP_time_limits = Int64[1, T, 2*T, 3*T]       

    ### PRECOMPUTE DESIGN MATRIX ###
    X      = ones(T, 2);
    X[:,2] = 1:T;
    M      = eye(T)-X*inv(X'X)*X';

    for Scenario_num in Scenario_range
      for σ in σ_range
        for Sim_num in Sim_range
        
          ### READ IN DATA FOR SIMULATION ###
          Read_path = string(Path_stem, "Experiment/Data/", string(P), string(/), string(T), string(/), string(Scenario_num), "_", string(σ), "_", string(Sim_num), ".csv")
          Data      = read_partitions(Read_path, T)

          for N in N_range

            ### SET THE SEED  ###
            srand(convert(Int64, P + T*10 + Scenario_num*100 + σ*1000 + Sim_num*10000 + N*100000))

            ### BEGIN TIMING SIMULATION ###
            Total_start_time = time()

            ### RUN AND TIME HEURISTIC ###
            Heuristic_start_time   = time()
            (Heuristic_partitions) = run_heuristic(Data, P, T, N, M)
            Heuristic_run_time     = time() - Heuristic_start_time

            ### ESTIMATE PARAMETERS OF HEURISTIC SOLUTION ###
            (Heuristic_abs_obj, Alpha, Beta) = solve_estimation(Data, Heuristic_partitions, P, T)

            for Time_limit in MIP_time_limits

              ### PRINT PROGRESS TO SCREEN ###
              println("P:", P, " T:", T, " Sce num:", Scenario_num, " Sigma:", σ, " Sim num:", Sim_num,  " N:", N, "\tTime Limit:", Time_limit)

              ### RUN AND TIME MIP ###
              MIP_start_time = time()
              MIP_write_path = string(Path_stem, "Experiment/MIP_Summaries/", string(P), string(/), string(T), string(/), string(Scenario_num), "_", string(σ), "_", string(Sim_num), "_", string(N), "_", string(Time_limit), ".csv")
              (Optimized_abs_obj, Optimized_partitions) = run_MIP(Data, Heuristic_partitions, Alpha, Beta, P, T, MIP_write_path, Time_limit, MIP_seed, Num_threads)
              MIP_run_time = time() - MIP_start_time

              ### END TIMING SIMULATION ###
              Total_run_time = time() - Total_start_time

              ### WRITE SOLUTION RESULTS TO FILE ###
              Heuristic_write_path = string(Path_stem, "Experiment/Heuristic_Solutions/", string(P), string(/), string(T), string(/), string(Scenario_num), "_", string(σ), "_", string(Sim_num), "_", string(N), "_", string(Time_limit), ".csv")
              Optimized_write_path = string(Path_stem, "Experiment/MIP_Solutions/",       string(P), string(/), string(T), string(/), string(Scenario_num), "_", string(σ), "_", string(Sim_num), "_", string(N), "_", string(Time_limit), ".csv")
              write_partitions(Heuristic_partitions, Heuristic_write_path, P, T)
              write_partitions(Optimized_partitions, Optimized_write_path, P, T)

              ### CALCULATE TOTAL RSS FOR EACH SOLUTION ###
              Heuristic_RSS       = calc_RSS(Heuristic_partitions, P, T, M)
              Optimized_RSS       = calc_RSS(Optimized_partitions, P, T, M)
              Total_heuristic_RSS = sum(Heuristic_RSS)
              Total_optimized_RSS = sum(Optimized_RSS)

              ### WRITE SUMMARY RESULTS TO FILE ###
              Summary_path = string(Path_stem, "Experiment/Simulation_Summaries/", string(P), string(/), string(T), string(/), string(Scenario_num), "_", string(σ), "_", string(Sim_num), "_", string(N), "_", string(Time_limit), ".csv")
              open(Summary_path,"w") do fp
                println(fp, "P,T,Scenario_num,Sigma,Sim_num,N,MIP_Time_Limit,Heuristic_run_time,MIP_run_time,Total_run_time,Heuristic_abs_obj,Optimized_abs_obj,Heuristic_RSS,Optimized_RSS")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", Heuristic_run_time, ",", MIP_run_time, ",", Total_run_time, ",", Heuristic_abs_obj, ",", Optimized_abs_obj, ",", Total_heuristic_RSS, ",", Total_optimized_RSS)
              end

            end # MIP_Times
          end # N_range
        end # Sim_range
      end # σ_range
    end # Scenario_range
  end # T_range
end # P_range