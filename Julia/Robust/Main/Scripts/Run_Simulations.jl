using Gurobi, JuMP

#### CHANGE TO LOCAL GIT DIRECTORY ###
const Path_stem = "/Users/za25454/Documents/Academic/Research/Git/Multi-Target-Tracking/Julia/Robust/"

### LOAD REQUIRED FUNCTIONS/SCRIPTS ###
include(string(Path_stem, "Functions/Miscellaneous/Read_Partitions.jl"))
include(string(Path_stem, "Functions/Miscellaneous/Write_Partitions.jl"))
include(string(Path_stem, "Functions/Miscellaneous/Run_Precompiler.jl"))
include(string(Path_stem, "Functions/Miscellaneous/Create_Exp_Directories.jl"))

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

const P_min             = 4                 # Minimum of target range
const P_step            = 2                 # Step size of target range
const P_max             = 10                # Maximum of target range

const T_min             = 4                 # Minimum of time range
const T_step            = 2                 # Step size of time range
const T_max             = 10                # Maximum of time range

const Scenario_min      = 1                 # Starting range of scenario numbers
const Scenario_max      = 20                # Ending range of scenario numbers

const γ_min             = 0.8               # Minimum missed detection probability
const γ_step            = 0.5               # Missed detection probability step size
const γ_max             = 1.0               # Maximum missed detection probability

const λ_min             = 0.5               # Minimum false alarm rate
const λ_step            = 0.5               # Missed false alarm rate step size
const λ_max             = 1.0               # Maximum false alarm rate

const Sim_min           = 1                 # Starting range of perturbations
const Sim_max           = 10                # Ending range of perturbations 

const N_1               = 100               # 1st N to run heuristic 
const N_2               = 1000              # 2nd N to run heuristic 
const N_3               = 10000             # 3rd N to run heuristic 

const θ_min             = 0.1               # Minimum false alarm penalty
const θ_step            = 0.1               # False alarm penalty step size
const θ_max             = 0.2               # Maximum false alarm penalty

const ϕ_min             = 0.1               # Minimum missed detection penalty
const ϕ_step            = 0.1               # Missed detection penalty step size
const ϕ_max             = 0.2               # Maximum missed detection penalty

const MIP_seed          = 5271992           # Set gurobi seed
const Num_threads       = 1                 # Set gurobi thread limit

### CONSTRUCT RANGES ###
P_range           = collect(P_min:P_step:P_max)               # Range of targets 
T_range           = collect(T_min:T_step:T_max)               # Range of time steps
Scenario_range    = collect(Scenario_min:1:Scenario_max)      # Range of scenarios
γ_range           = collect(γ_min:γ_step:γ_max)               # Range of missed detection probabilities
λ_range           = collect(λ_min:λ_step:λ_max)               # Range of false alarm rates
Sim_range         = collect(Sim_min:1:Sim_max)                # Range of perturbation sims
N_range           = Int64[N_1, N_2, N_3]                      # Range of heuristic starting points
θ_range           = collect(θ_min:θ_step:θ_max)               # Range of missed detection penalties
ϕ_range           = collect(ϕ_min:ϕ_step:ϕ_max)               # Range of false alarm penalties

### CREATE REQUIRED DIRECTORIES ###
create_directories(Path_stem, P_range, T_range, Scenario_range)

#######################################################
###    STEP 4: RUN EXPERIMENT ON SIMULATED DATA    ####
#######################################################

### PRECOMPILE CODE TO ELIMINATE GARBAGE TIME ###
run_precompiler()

for P in P_range
  
  ### Define variable parameters ###
  if P <= 6
    Grid_size = 5                               # Grid size
    σ_range   = Float64[0.5, 1.0, 2.5, 5.0]     # Range of scenaro noise
  else
    Grid_size = 10                              # Grid size
    σ_range   = Float64[1.0, 2.0, 5.0, 10.0]    # Range of scenaro noise
  end

  for T in T_range

    ### Define range of times to run MIP
    MIP_time_limits = Int64[1, T, 2*T, 3*T]       

    ### PRECOMPUTE DESIGN MATRIX ###
    X      = ones(T, 2);
    X[:,2] = 1:T;
    M      = eye(T)-X*inv(X'X)*X';

    for Scenario_num in Scenario_range
      for σ in σ_range
        for γ in γ_range
          for λ in λ_range
            for Sim_num in Sim_range
            
              ### READ IN DATA FOR SIMULATION ###
              Read_path = string(Path_stem, "Experiment/Data/", string(P), string(/), string(T), string(/), string(Scenario_num), "_", string(σ), "_", string(γ), "_", string(λ), "_", string(Sim_num), ".csv")    
              Data      = read_partitions(Read_path, T)

              ### DETERMINE RANGE OF POSSIBLE NUMBER OF TARGETS  ###
              Num_detections = zeros(Int64, T)

              for t = 1:T
                Num_detections[t] = length(Data[t])
              end

              P_test_min   = minimum(Num_detections)
              P_test_max   = maximum(Num_detections)
              P_test_range = collect(P_test_min:1:P_test_max)
    
              for θ in θ_range
                for ϕ in ϕ_range
                  for Test_P in P_test_range

                    ### PREPARE DATA FOR HEURISTIC ###
                    (Prepared_data, Lengths) = prepare_data(Data, Num_detections, Test_P, T)
                        
                    for N in N_range

                      ### SET THE SEED  ###
                      srand(convert(Int64, P + T*10 + Scenario_num*100 + σ*1000 + γ*10000 + λ*100000 + Sim_num*1000000 + θ*10000000 + ϕ*100000000 + Test_P*1000000000 + N*10000000000))

                      ### BEGIN TIMING SIMULATION ###
                      Total_start_time = time()

                      ### RUN AND TIME HEURISTIC ###
                      Heuristic_start_time   = time()
                      (Heuristic_partitions) = run_robust_heuristic(Prepared_data, Num_detections, Lengths, N, Test_P, T, θ, ϕ)
                      Heuristic_run_time     = time() - Heuristic_start_time

                      ### ESTIMATE PARAMETERS OF HEURISTIC SOLUTION ###
                      (Heuristic_abs_obj, Alpha, Beta) = solve_estimation(Data, Heuristic_partitions, Num_detections, Grid_size, Test_P, T, θ, ϕ)

                      for Time_limit in MIP_time_limits

                        ### PRINT PROGRESS TO SCREEN ###
                        println("P:", P, " T:", T, " Sce num:", Scenario_num, " Sigma:", σ, " Gamma:", γ, " Lambda:", λ, " Sim num:", Sim_num, " Theta:", θ, " Phi:", ϕ, " Test P:", Test_P, " N:", N, "\tTime Limit:", Time_limit)

                        ### RUN AND TIME MIP ###
                        MIP_start_time = time()
                        MIP_write_path = string(Path_stem, "Experiment/MIP_Summaries/", string(P), string(/), string(T), string(/), string(Scenario_num), string(/), string(σ), string(/), string(γ), "_", string(λ), "_", string(Sim_num), "_", string(θ), "_", string(ϕ), "_", string(Test_P), "_", string(N), "_", string(Time_limit), ".csv")
                        (Optimized_abs_obj, Optimized_partitions) = run_robust_MIP(Data, Heuristic_partitions,  Num_detections, Alpha, Beta, Grid_size, Test_P, T, θ, ϕ, MIP_write_path, Time_limit, MIP_seed, Num_threads)
                        MIP_run_time = time() - MIP_start_time

                        ### END TIMING SIMULATION ###
                        Total_run_time = time() - Total_start_time

                        ### STORE LENGTHS OF OPTIMIZED PARTITIONS ###
                        Lengths = zeros(Int64, T)
                        for t in 1:T 
                          Lengths[t] = length(Optimized_partitions[t])
                        end

                        ### WRITE SOLUTION RESULTS TO FILE ###
                        Heuristic_write_path = string(Path_stem, "Experiment/Heuristic_Solutions/", string(P), string(/), string(T), string(/), string(Scenario_num), string(/), string(σ), string(/), string(γ), "_", string(λ), "_", string(Sim_num), "_", string(θ), "_", string(ϕ), "_", string(Test_P), "_", string(N), "_", string(Time_limit), ".csv")
                        Optimized_write_path = string(Path_stem, "Experiment/MIP_Solutions/",       string(P), string(/), string(T), string(/), string(Scenario_num), string(/), string(σ), string(/), string(γ), "_", string(λ), "_", string(Sim_num), "_", string(θ), "_", string(ϕ), "_", string(Test_P), "_", string(N), "_", string(Time_limit), ".csv")
                        write_partitions(Heuristic_partitions, Heuristic_write_path, T)
                        write_partitions(Optimized_partitions, Optimized_write_path, T)

                        ### CALCULATE TOTAL RSS FOR EACH SOLUTION ###
                        (Heuristic_RSS, Heuristic_Total_FA, Heuristic_Total_MD) = calc_obj(Test_P, T, Heuristic_partitions, Lengths)
                        (Optimized_RSS, Optimized_Total_FA, Optimized_Total_MD) = calc_obj(Test_P, T, Optimized_partitions, Lengths)
                        Heuristic_RSS_obj = sum(Heuristic_RSS) + θ*Heuristic_Total_FA + ϕ*Heuristic_Total_MD
                        Optimized_RSS_obj = sum(Optimized_RSS) + θ*Optimized_Total_FA + ϕ*Optimized_Total_MD

                        ### WRITE SUMMARY RESULTS TO FILE ###
                        Summary_path = string(Path_stem, "Experiment/Simulation_Summaries/", string(P), string(/), string(T), string(/), string(Scenario_num), string(/), string(σ), string(/), string(γ), "_", string(λ), "_", string(Sim_num), "_", string(θ), "_", string(ϕ), "_", string(Test_P), "_", string(N), "_", string(Time_limit), ".csv")
                        open(Summary_path,"w") do fp
                          println(fp, "P,T,Scenario_num,Sigma,Gamma,Lambda,Sim_num,Theta,Phi,Test_P,N,MIP_Time_Limit,Heuristic_run_time,MIP_run_time,Total_run_time,Heuristic_abs_obj,Optimized_abs_obj,Heuristic_RSS_obj,Optimized_RSS_obj")
                          println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", γ, ",", λ, ",", Sim_num, ",", θ, ",", ϕ, ",", Test_P, ",", N, ",", Time_limit, ",", Heuristic_run_time, ",", MIP_run_time, ",", Total_run_time, ",", Heuristic_abs_obj, ",", Optimized_abs_obj, ",", Heuristic_RSS_obj, ",", Optimized_RSS_obj)
                        end

                      end # MIP_Times
                    end # N_range
                  end # P_test_range
                end # ϕ_range
              end # θ_range
            end # Sim_range
          end # λ_range
        end # γ_range
      end # σ_range
    end # Scenario_range
  end # T_range
end # P_range