### LIMIT THREAD COUNT ###
blas_set_num_threads(1)

### LOAD REQUIRED PACKAGES ###
using Gurobi, JuMP

#### CHANGE TO LOCAL GIT DIRECTORY ###
const Path_stem = "/home/gridsan/ZA25454/Robust/"

### LOAD REQUIRED FUNCTIONS/SCRIPTS ###
include(string(Path_stem, "Functions/Miscellaneous/Read_Partitions.jl"))
include(string(Path_stem, "Functions/Miscellaneous/Write_Partitions.jl"))
include(string(Path_stem, "Functions/Miscellaneous/Run_Precompiler.jl"))

include(string(Path_stem, "Heuristic/Calculate_Objective.jl"))
include(string(Path_stem, "Heuristic/Update_Objective.jl"))
include(string(Path_stem, "Heuristic/Prepare_Data.jl"))
include(string(Path_stem, "Heuristic/Robust_Heuristic_Swap.jl"))
include(string(Path_stem, "Heuristic/Run_Robust_Heuristic.jl"))

include(string(Path_stem, "Optimization/Solve_Estimation.jl"))
include(string(Path_stem, "Optimization/Robust_MIP.jl"))


#####################################################
###    STEP 0: DEFINE EXPERIMENTAL PARAMETERS    ####
#####################################################

const P                 = parse(Int,     ARGS[1])   # Number of targets
const T                 = parse(Int,     ARGS[2])   # Number of time steps
 
const Scenario_num      = parse(Int,     ARGS[3])   # Scenario number
const σ                 = parse(Float64, ARGS[4])   # Noise parameter

const γ                 = parse(Float64, ARGS[5])   # Missed Detection probability
const λ                 = parse(Float64, ARGS[6])   # False Alarm Rate

const Sim_min           = 1                         # Starting range of perturbations
const Sim_max           = 1                         # Ending range of perturbations 

const N                 = 1000                      # Number of starting points for heuristic 

const θ_min             = 0.1                       # Minimum false alarm penalty
const θ_step            = 0.1                       # False alarm penalty step size
const θ_max             = 0.5                       # Maximum false alarm penalty

const ϕ_min             = 0.1                       # Minimum missed detection penalty
const ϕ_step            = 0.1                       # Missed detection penalty step size
const ϕ_max             = 0.5                       # Maximum missed detection penalty

const Grid_size         = 10                        # Size of window for targets to exist within
const MIP_seed          = 5271992                   # Set gurobi seed
const Num_threads       = 1                         # Set gurobi thread limit

### CONSTRUCT RANGES ###
Sim_range         = collect(Sim_min:1:Sim_max)                # Range of simulations
θ_range           = collect(θ_min:θ_step:θ_max)               # Range of missed detection penalties
ϕ_range           = collect(ϕ_min:ϕ_step:ϕ_max)               # Range of false alarm penalties

#######################################################
###    STEP 4: RUN EXPERIMENT ON SIMULATED DATA    ####
#######################################################

### WRITE SUMMARY RESULTS TO FILE ###
Summary_path = string(Path_stem, "Experiment/Simulation_Summaries/", string(P), "_", string(T), "_", string(Scenario_num), "_", string(σ), "_", string(γ), "_", string(λ), ".csv")
open(Summary_path,"w") do fp
  println(fp, "P,T,Scenario_num,Sigma,Gamma,Lambda,Sim_num,Theta,Phi,Test_P,N,MIP_Time_Limit,Heuristic_run_time,MIP_run_time,Total_run_time,Heuristic_abs_obj,Optimized_abs_obj,Heuristic_RSS_obj,Optimized_RSS_obj")
end

### PRECOMPILE CODE TO ELIMINATE GARBAGE TIME ###
run_precompiler()

### Define range of times to run MIP
MIP_time_limits = Int64[1, T, 2*T, 3*T]     

### PRECOMPUTE DESIGN MATRIX ###
X      = ones(T, 2);
X[:,2] = 1:T;
M      = eye(T)-X*inv(X'X)*X';

for Sim_num in Sim_range

  ### RUN GARBAGE COLLECTOR ###
  gc()

  ### READ IN DATA FOR SIMULATION ###
  Read_path = string(Path_stem, "Experiment/Data/", string(P), string(/), string(T), string(/), string(Scenario_num), "_", string(σ), "_", string(γ), "_", string(λ), "_", string(Sim_num), ".csv")    
  Data      = read_partitions(Read_path)

  ### DETERMINE RANGE OF POSSIBLE NUMBER OF TARGETS  ###
  Num_detections = zeros(Int64, T)

  for t = 1:T
    Num_detections[t] = length(Data[t])
  end

  P_test_min   = minimum(Num_detections)
  P_test_max   = maximum(Num_detections)
  P_test_range = collect(P_test_min:1:P_test_max)

  for θ in θ_range

    ### RUN GARBAGE COLLECTOR ###
    gc()

    for ϕ in ϕ_range

      ### RUN GARBAGE COLLECTOR ###
      gc()

      for Test_P in P_test_range

        ### RUN GARBAGE COLLECTOR ###
        gc()

        ### PREPARE DATA FOR HEURISTIC ###
        (Prepared_data, Lengths) = prepare_data(Data, Num_detections, Test_P, T)
            
        ### SET THE SEED  ###
        srand(convert(Int64, P + T*10 + Scenario_num*100 + σ*1000 + γ*10000 + λ*100000 + Sim_num*1000000 + θ*10000000 + ϕ*100000000 + Test_P*1000000000))

        ### RUN AND TIME HEURISTIC ###
        Heuristic_start_time   = time()
        (Heuristic_partitions) = run_robust_heuristic(Prepared_data, Num_detections, Lengths, N, Test_P, T, θ, ϕ)
        Heuristic_run_time     = time() - Heuristic_start_time

        ### ESTIMATE PARAMETERS OF HEURISTIC SOLUTION ###
        (Heuristic_abs_obj, Alpha, Beta) = solve_estimation(Data, Heuristic_partitions, Num_detections, Grid_size, Test_P, T, θ, ϕ)

        ### WRITE SOLUTION RESULTS TO FILE ###
        Heuristic_write_path = string(Path_stem, "Experiment/Heuristic_Solutions/", string(P), string(/), string(T), string(/), string(Scenario_num), string(/), string(σ), string(/), string(γ), "_", string(λ), "_", string(Sim_num), "_", string(θ), "_", string(ϕ), "_", string(Test_P), ".csv")  
        write_partitions(Heuristic_partitions, Heuristic_write_path, T)

        ### CALCULATE TOTAL RSS FOR EACH SOLUTION ###
        (Heuristic_RSS, Heuristic_Total_FA, Heuristic_Total_MD) = calc_obj(Test_P, T, Heuristic_partitions, Lengths)
        Heuristic_RSS_obj = sum(Heuristic_RSS) + θ*Heuristic_Total_FA + ϕ*Heuristic_Total_MD

        for Time_limit in MIP_time_limits

          ### RUN GARBAGE COLLECTOR ###
          gc()

          ### PRINT PROGRESS TO SCREEN ###
          println("P:", P, " T:", T, " Sce num:", Scenario_num, " Sigma:", σ, " Gamma:", γ, " Lambda:", λ, " Sim num:", Sim_num, " Theta:", θ, " Phi:", ϕ, " Test P:", Test_P, "\tTime Limit:", Time_limit)

          ### RUN AND TIME MIP ###
          MIP_start_time = time()
          MIP_write_path = string(Path_stem, "Experiment/MIP_Summaries/", string(P), string(/), string(T), string(/), string(Scenario_num), string(/), string(σ), string(/), string(γ), "_", string(λ), "_", string(Sim_num), "_", string(θ), "_", string(ϕ), "_", string(Test_P), "_", string(Time_limit), ".csv")
          (Optimized_abs_obj, Optimized_partitions) = run_robust_MIP(Data, Heuristic_partitions,  Num_detections, Alpha, Beta, Grid_size, Test_P, T, θ, ϕ, MIP_write_path, Time_limit, MIP_seed, Num_threads)
          MIP_run_time = time() - MIP_start_time

          ### CALCULATE TOTAL RUN TIME ###
          Total_run_time = Heuristic_run_time + MIP_run_time

          ### PREPARE OPTIMIZED PARTIONS FOR OBJECTIVE CALCULATION ###
          (Prepared_optimized, Lengths) = prepare_data(Optimized_partitions, Num_detections, Test_P, T)

          ### WRITE SOLUTION RESULTS TO FILE ###
          Optimized_write_path = string(Path_stem, "Experiment/MIP_Solutions/", string(P), string(/), string(T), string(/), string(Scenario_num), string(/), string(σ), string(/), string(γ), "_", string(λ), "_", string(Sim_num), "_", string(θ), "_", string(ϕ), "_", string(Test_P), "_", string(Time_limit), ".csv")
          write_partitions(Optimized_partitions, Optimized_write_path, T)

          ### CALCULATE TOTAL RSS FOR EACH SOLUTION ###
          (Optimized_RSS, Optimized_Total_FA, Optimized_Total_MD) = calc_obj(Test_P, T, Prepared_optimized, Lengths)
          Optimized_RSS_obj = sum(Optimized_RSS) + θ*Optimized_Total_FA + ϕ*Optimized_Total_MD

          ### WRITE SUMMARY RESULTS TO FILE ###
          open(Summary_path,"a") do fp
            println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", γ, ",", λ, ",", Sim_num, ",", θ, ",", ϕ, ",", Test_P, ",", N, ",", Time_limit, ",", Heuristic_run_time, ",", MIP_run_time, ",", Total_run_time, ",", Heuristic_abs_obj, ",", Optimized_abs_obj, ",", Heuristic_RSS_obj, ",", Optimized_RSS_obj)
          end

        end # MIP_Times
      end # P_test_range
    end # ϕ_range
  end # θ_range
end # Sim_range
