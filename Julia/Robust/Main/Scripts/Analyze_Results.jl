using Gurobi, JuMP

#### CHANGE TO LOCAL GIT DIRECTORY ###
const Path_stem = "/Users/za25454/Documents/Academic/Research/Git/Multi-Target-Tracking/Julia/Robust/"

### LOAD FUNCTIONS/SCRIPTS ###
include(string(Path_stem, "Functions/Analysis/Calculate_Accuracy.jl"))
include(string(Path_stem, "Functions/Analysis/Calculate_Delta.jl"))
include(string(Path_stem, "Functions/Analysis/Estimate_Position.jl"))
include(string(Path_stem, "Functions/Analysis/Random_Assignment.jl"))

include(string(Path_stem, "Functions/Miscellaneous/Read_Partitions.jl"))
include(string(Path_stem, "Functions/Miscellaneous/Write_Positions.jl"))

include(string(Path_stem, "Heuristic/Prepare_Data.jl"))

include(string(Path_stem, "Optimization/Solve_Assignment.jl"))
include(string(Path_stem, "Optimization/Solve_Estimation.jl"))

include(string(Path_stem, "Functions/Scenario/Calculate_Density.jl"))


#####################################################
###    STEP 0: DEFINE EXPERIMENTAL PARAMETERS    ####
#####################################################

const P_min             = 4                   # Minimum of target range
const P_step            = 2                   # Step size of target range
const P_max             = 10                  # Maximum of target range

const T_min             = 4                   # Minimum of time range
const T_step            = 2                   # Step size of time range
const T_max             = 10                  # Maximum of time range

const Num_parallel      = 1                   # Number of scenarios to generate using "parallel" method
const Num_crossing      = 1                   # Number of scenarios to generate using "crossing" method

const σ_1               = 0.1                 # 1st noise parameter value
const σ_2               = 0.5                 # 2nd noise parameter value
const σ_3               = 1.0                 # 3rd noise parameter value
const σ_4               = 2.0                 # 4th noise parameter value

const γ_min             = 0.80                # Minimum missed detection probability
const γ_step            = 0.05                # Missed detection probability step size
const γ_max             = 0.95                # Maximum missed detection probability

const λ_1               = 0.1                 # 1st false alarm rate
const λ_2               = 0.5                 # 2nd false alarm rate
const λ_3               = 1.0                 # 3rd false alarm rate
const λ_4               = 2.0                 # 4th false alarm rate

const θ_min             = 0.1                 # Minimum false alarm penalty
const θ_step            = 0.1                 # False alarm penalty step size
const θ_max             = 0.5                 # Maximum false alarm penalty

const ϕ_min             = 0.1                 # Minimum missed detection penalty
const ϕ_step            = 0.1                 # Missed detection penalty step size
const ϕ_max             = 0.5                 # Maximum missed detection penalty

const Sim_min           = 1                   # Starting range of perturbations
const Sim_max           = 2                   # Ending range of perturbations 

const Grid_size         = 10                  # Size of window for targets to exist within
const MIP_seed          = 5271992             # Set gurobi seed
const Num_threads       = 1                   # Set gurobi thread limit

Num_scenarios = Num_parallel + Num_crossing   # Number of total scenarios to generate

### CONSTRUCT RANGES ###
P_range           = collect(P_min:P_step:P_max)    # Range of targets 
T_range           = collect(T_min:T_step:T_max)    # Range of time steps
Scenario_range    = collect(1:1:Num_scenarios)     # Range of scenarios
σ_range           = Float64[σ_1, σ_2, σ_3, σ_4]    # Range of scenaro noise
γ_range           = collect(γ_min:γ_step:γ_max)    # Range of missed detection probabilities
λ_range           = Float64[λ_1, λ_2, λ_3, λ_4]    # Range of false alarm rates
#λ_range           = Float64[λ_4]
θ_range           = collect(θ_min:θ_step:θ_max)    # Range of missed detection penalties
ϕ_range           = collect(ϕ_min:ϕ_step:ϕ_max)    # Range of false alarm penalties
Sim_range         = collect(Sim_min:1:Sim_max)     # Range of simulations

### CREATE REQUIRED DIRECTORIES ###
mypath = string(Path_stem, "Results")
isdir(mypath) || mkdir(mypath)

mypath = string(Path_stem, "Results/Files")
isdir(mypath) || mkdir(mypath)

# mypath = string(Path_stem, "Results/Plots")
# isdir(mypath) || mkdir(mypath)

#################################################
###    STEP 5: ANALYZE SIMULATION RESULTS    ####
#################################################
Summary_path = string(Path_stem, "Results/Files/Summary.csv")
open(Summary_path,"w") do fp
  println(fp, "P,T,Scenario_num,Sigma,Gamma,Lambda,Sim_num,Theta,Phi,Test_P,MIO_Time,Rho,Accuracy,Delta,Objective,Solution_Type,Scenario_Type")
end

for P in P_range
  for T in T_range

    ### Define range of times to run MIP
    MIP_time_limits = Int64[1, T, 2*T, 3*T] 

    for Scenario_num in Scenario_range

      ### READ IN AND STORE TRUE POSITIONS ###
      True_path = string(Path_stem, "Experiment/True_Positions/", string(P), "_", string(T), "_", string(Scenario_num), ".csv")
      True_positions = read_partitions(True_path)

      for σ in σ_range

        ### CALCULATE RHO FOR THE CURRENT SIMULATION ###
        ρ = calc_density(True_positions, P, T, σ)

        for γ in γ_range
          for λ in λ_range
            for Sim_num in Sim_range

              ### READ IN AND STORE IDEAL ASSIGNMENTS ###
              Ideal_path = string(Path_stem, "Experiment/Data_Key/", string(P), string(/), string(T), string(/), string(Scenario_num), "_", string(σ), "_", string(γ), "_", string(λ), "_", string(Sim_num), ".csv")
              Raw_ideal  = read_partitions(Ideal_path)

              ### READ IN AND STORE DATA ###
              Data_path = string(Path_stem, "Experiment/Data/", string(P), string(/), string(T), string(/), string(Scenario_num), "_", string(σ), "_", string(γ), "_", string(λ), "_", string(Sim_num), ".csv") 
              Data = read_partitions(Data_path)

              ### DETERMINE RANGE OF POSSIBLE NUMBER OF TARGETS  ###
              Num_detections = zeros(Int64, T)

              for t = 1:T
                Num_detections[t] = length(Data[t])
              end

              P_test_min   = minimum(Num_detections)
              P_test_max   = maximum(Num_detections)
              P_test_range = collect(P_test_min:1:P_test_max)

              ### PREPARE PARTITIONS FOR USE ###
              (Prepared_data,    Lengths) = prepare_data(Data,      Num_detections, P, T)
              (Ideal_partitions, Lengths) = prepare_data(Raw_ideal, Num_detections, P, T)

              ### SET THE SEED  ###
              srand(convert(Int64, P + T*10 + Scenario_num*100 + σ*1000 + γ*10000 + λ*100000 + Sim_num*1000000))

              ### GENERATE RANDOMIZED ASSIGNMENTS ###
              Random_partitions = random_assignment(Prepared_data, T)

              for θ in θ_range
                for ϕ in ϕ_range

                  ### CALCULATE ESTIMATED PARAMETERS & OBJECTIVE SCORE ###
                  (Random_objective, Random_alpha, Random_beta) = solve_estimation(Data, Random_partitions, Num_detections, Grid_size, P, T, θ, ϕ)

                  (Ideal_objective,  Ideal_alpha,  Ideal_beta)  = solve_estimation(Data, Ideal_partitions,  Num_detections, Grid_size, P, T, θ, ϕ)

                  ### CALCULATE ESTIMATED POSITIONS ###
                  Random_positions = estimate_positions(Random_alpha, Random_beta, P, T)
                  Ideal_positions  = estimate_positions(Ideal_alpha,  Ideal_beta,  P, T)

                  ### SOLVE TRAJECTORY ASSIGNMENT MATCHING ###
                  Ideal_assignments  = collect(1:P)
                  Random_assignments = solve_traj_assignment(True_positions, Random_positions, P, P, T)

                  ### CALCULATE ACCURACY ###
                  Ideal_accuracy  = calc_accuracy(Raw_ideal, Ideal_partitions,  Ideal_assignments,  P, P, T)
                  Random_accuracy = calc_accuracy(Raw_ideal, Random_partitions, Random_assignments, P, P, T)

                  ### CALCULATE DELTA ###
                  Random_δ  = calc_delta(True_positions, Random_positions, Random_assignments, P, P, T)
                  Ideal_δ   = calc_delta(True_positions, Ideal_positions,  Ideal_assignments,  P, P, T)

                  for Test_P in P_test_range

                    ### READ IN AND STORE HEURISTIC PARTITIONS ###
                    Heuristic_path = string(Path_stem, "Experiment/Heuristic_Solutions/", string(P), string(/), string(T), string(/), string(Scenario_num), string(/), string(σ), string(/), string(γ), "_", string(λ), "_", string(Sim_num), "_", string(θ), "_", string(ϕ), "_", string(Test_P), ".csv")
                    Heuristic_partitions = read_partitions(Heuristic_path)

                    ### CALCULATE ESTIMATED PARAMETERS & OBJECTIVE SCORE ###
                    (Heuristic_objective, Heuristic_alpha, Heuristic_beta) = solve_estimation(Data, Heuristic_partitions, Num_detections, Grid_size, Test_P, T, θ, ϕ)

                    ### CALCULATE ESTIMATED POSITIONS ###
                    Heuristic_positions = estimate_positions(Heuristic_alpha, Heuristic_beta, Test_P, T)

                    ### SOLVE TRAJECTORY ASSIGNMENT MATCHING ###
                    Heuristic_assignments = solve_traj_assignment(True_positions, Heuristic_positions, P, Test_P, T)

                    ### CALCULATE ACCURACY ###
                    Heuristic_accuracy = calc_accuracy(Raw_ideal, Heuristic_partitions, Heuristic_assignments, P, Test_P, T)

                    ### CALCULATE DELTA ###
                    Heuristic_δ  = calc_delta(True_positions, Heuristic_positions, Heuristic_assignments, P, Test_P, T)

                    for Time_limit in MIP_time_limits


                      ### PRINT PROGRESS TO SCREEN ###
                      println("P:", P, " T:", T, " Sce_num:", Scenario_num, " Sigma:", σ, " Gamma:", γ, " Lambda:", λ, " Sim_num:", Sim_num, " Theta:", θ, " Phi:", ϕ, " Test_P:", Test_P, "\tTime Limit:", Time_limit)
 
                      ### READ IN AND STORE OPTIMIZED PARTITIONS ###
                      Optimized_path = string(Path_stem, "Experiment/MIP_Solutions/", string(P), string(/), string(T), string(/), string(Scenario_num), string(/), string(σ), string(/), string(γ), "_", string(λ), "_", string(Sim_num), "_", string(θ), "_", string(ϕ), "_", string(Test_P), "_", string(Time_limit), ".csv")
                      Raw_optimized = read_partitions(Optimized_path)

                      ### PREPARE PARTITIONS FOR USE ###
                      (Optimized_partitions, Lengths) = prepare_data(Raw_optimized, Num_detections, P, T)

                      ### CALCULATE ESTIMATED PARAMETERS & OBJECTIVE SCORE ###
                      (Optimized_objective, Optimized_alpha,  Optimized_beta) = solve_estimation(Data, Optimized_partitions, Num_detections, Grid_size, Test_P, T, θ, ϕ)

                      ### CALCULATE ESTIMATED POSITIONS ###
                      Optimized_positions = estimate_positions(Optimized_alpha,  Optimized_beta, Test_P, T)

                      ### SOLVE TRAJECTORY ASSIGNMENT MATCHING ###
                      Optimized_assignments = solve_traj_assignment(True_positions, Optimized_positions, P, Test_P, T)

                      ### CALCULATE ACCURACY ###
                      Optimized_accuracy = calc_accuracy(Raw_ideal, Optimized_partitions, Optimized_assignments, P, Test_P, T)

                      ### CALCULATE DELTA ###
                      Optimized_δ  = calc_delta(True_positions, Optimized_positions, Optimized_assignments, P, Test_P, T)

                      ### WRITE RESULTS TO FILE ###
                      if Scenario_num <= Num_parallel

                        open(Summary_path, "a") do fp
                          println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", γ, ",", λ, ",", Sim_num, ",", θ, ",", ϕ, ",", Test_P, ",", Time_limit, ",", ρ, ",", Random_accuracy,    ",", Random_δ,    ",", Random_objective,    ",", "Random",     ",", "Parallel")
                          println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", γ, ",", λ, ",", Sim_num, ",", θ, ",", ϕ, ",", Test_P, ",", Time_limit, ",", ρ, ",", Heuristic_accuracy, ",", Heuristic_δ, ",", Heuristic_objective, ",", "Heuristic",  ",", "Parallel")
                          println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", γ, ",", λ, ",", Sim_num, ",", θ, ",", ϕ, ",", Test_P, ",", Time_limit, ",", ρ, ",", Optimized_accuracy, ",", Optimized_δ, ",", Optimized_objective, ",", "Optimized",  ",", "Parallel")
                          println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", γ, ",", λ, ",", Sim_num, ",", θ, ",", ϕ, ",", Test_P, ",", Time_limit, ",", ρ, ",", Ideal_accuracy,     ",", Ideal_δ,     ",", Ideal_objective,     ",", "Ideal",      ",", "Parallel")
                        end

                      else

                        open(Summary_path, "a") do fp
                          println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", γ, ",", λ, ",", Sim_num, ",", θ, ",", ϕ, ",", Test_P, ",", Time_limit, ",", ρ, ",", Random_accuracy,    ",", Random_δ,    ",", Random_objective,    ",", "Random",     ",", "Crossing")
                          println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", γ, ",", λ, ",", Sim_num, ",", θ, ",", ϕ, ",", Test_P, ",", Time_limit, ",", ρ, ",", Heuristic_accuracy, ",", Heuristic_δ, ",", Heuristic_objective, ",", "Heuristic",  ",", "Crossing")
                          println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", γ, ",", λ, ",", Sim_num, ",", θ, ",", ϕ, ",", Test_P, ",", Time_limit, ",", ρ, ",", Optimized_accuracy, ",", Optimized_δ, ",", Optimized_objective, ",", "Optimized",  ",", "Crossing")
                          println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", γ, ",", λ, ",", Sim_num, ",", θ, ",", ϕ, ",", Test_P, ",", Time_limit, ",", ρ, ",", Ideal_accuracy,     ",", Ideal_δ,     ",", Ideal_objective,     ",", "Ideal",      ",", "Crossing")
                        end

                      end
                    
                    end # MIP_Times
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