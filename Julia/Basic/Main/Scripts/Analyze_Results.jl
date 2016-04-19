using Gurobi, JuMP

#### CHANGE TO LOCAL GIT DIRECTORY ###
const Path_stem = "/Users/za25454/Documents/Academic/Research/Git/Multi-Target-Tracking/Julia/Basic/"

### LOAD FUNCTIONS/SCRIPTS ###
include(string(Path_stem, "Functions/Analysis/Calculate_Accuracy.jl"))
include(string(Path_stem, "Functions/Analysis/Calculate_Delta.jl"))
include(string(Path_stem, "Functions/Analysis/Estimate_Position.jl"))
include(string(Path_stem, "Functions/Analysis/Random_Assignment.jl"))

include(string(Path_stem, "Functions/Miscellaneous/Read_Partitions.jl"))
include(string(Path_stem, "Functions/Miscellaneous/Write_Positions.jl"))
include(string(Path_stem, "Functions/Miscellaneous/Create_Results_Directories.jl"))


include(string(Path_stem, "Optimization/Solve_Assignment.jl"))
include(string(Path_stem, "Optimization/Solve_Estimation.jl"))

include(string(Path_stem, "Functions/Scenario/Calculate_Density.jl"))


#####################################################
###    STEP 0: DEFINE EXPERIMENTAL PARAMETERS    ####
#####################################################

const P_min            = 4                   # Minimum of target range
const P_step           = 2                   # Step size of target range
const P_max            = 10                  # Maximum of target range

const T_min            = 4                   # Minimum of time range
const T_step           = 2                   # Step size of time range
const T_max            = 10                  # Maximum of time range

const Num_parallel     = 10                  # Number of scenarios to generate using "parallel" method
const Num_crossing     = 10                  # Number of scenarios to generate using "crossing" method

const σ_1              = 0.1                 # 1st noise parameter value
const σ_2              = 0.5                 # 2nd noise parameter value
const σ_3              = 1.0                 # 3rd noise parameter value
const σ_4              = 2.0                 # 4th noise parameter value
const σ_5              = 3.5                 # 4th noise parameter value
const σ_6              = 5.0                 # 4th noise parameter value

const Sim_min          = 1                   # Starting range of simulations
const Sim_max          = 10                  # Ending range of simulations

const N_1              = 100                 # 1st N to run heuristic 
const N_2              = 1000                # 2nd N to run heuristic 
const N_3              = 10000               # 3rd N to run heuristic 

Num_scenarios = Num_parallel + Num_crossing  # Number of total scenarios to generate

### CONSTRUCT RANGES ###
P_range        = collect(P_min:P_step:P_max) # Range of targets 
T_range        = collect(T_min:T_step:T_max) # Range of time steps
Scenario_range = collect(1:1:Num_scenarios)  # Range of scenarios
σ_range        = Float64[σ_1, σ_2, σ_3, σ_4, σ_5, σ_6] # Range of noise parameters
Sim_range      = collect(Sim_min:1:Sim_max)  # Range of simulations
N_range        = Int64[N_1, N_2, N_3]        # Range of heuristic starting points

### CREATE REQUIRED DIRECTORIES ###
create_directories(Path_stem, P_range, T_range)

#################################################
###    STEP 5: ANALYZE SIMULATION RESULTS    ####
#################################################
Accuracy_path = string(Path_stem, "Results/Files/Accuracy.csv")
open(Accuracy_path,"w") do fp
  println(fp, "P,T,Scenario_num,Sigma,Sim_num,N,MIO_Time,Rho,Rho_Type,Accuracy,Solution_Type,Scenario_Type")
end

Delta_path = string(Path_stem, "Results/Files/Delta.csv")
open(Delta_path,"w") do fp
  println(fp, "P,T,Scenario_num,Sigma,Sim_num,N,MIO_Time,Rho,Rho_Type,Delta,Solution_Type,Scenario_Type")
end

Objective_path = string(Path_stem, "Results/Files/Objective.csv")
open(Objective_path,"w") do fp
  println(fp, "P,T,Scenario_num,Sigma,Sim_num,N,MIO_Time,Rho,Rho_Type,Objective,Solution_Type,Scenario_Type")
end

for P in P_range
  for T in T_range

    ### Define range of times to run MIP
    MIP_time_limits = Int64[1, T, 2*T, 3*T] 

    for Scenario_num in Scenario_range

      ### READ IN AND STORE TRUE POSITIONS ###
      True_path = string(Path_stem, "Experiment/True_Positions/", string(P), "_", string(T), "_", string(Scenario_num), ".csv")
      True_positions = read_partitions(True_path, T)

      for σ in σ_range

        ### CALCULATE RHO FOR THE CURRENT SIMULATION ###
        (ρ1, ρ2, ρ3, ρ4) = calc_density(True_positions, P, T, σ)

        for Sim_num in Sim_range

          ### READ IN AND STORE IDEAL ASSIGNMENTS ###
          Ideal_path = string(Path_stem, "Experiment/Detections/", string(P), string(/), string(T), string(/), string(Scenario_num), "_", string(σ), "_", string(Sim_num), ".csv")
          Ideal_partitions  = read_partitions(Ideal_path, T)

          ### SET THE SEED ###
          srand(convert(Int64,P + T*10 + Scenario_num*100 + σ*1000 + Sim_num*10000))

          ### GENERATE RANDOMIZED ASSIGNMENTS ###
          Random_partitions = random_assignment(Ideal_partitions, T)

          for N in N_range
            for Time_limit in MIP_time_limits

            ### PRINT PROGRESS TO SCREEN ###
            println("P:", P, " T:", T, " Sce num:", Scenario_num, " Sigma:", σ, " Sim num:", Sim_num,  " N:", N, "\tTime Limit:", Time_limit)
 
            ### READ IN AND STORE HEURISTIC/OPTIMIZED PARTITIONS ###
            Heuristic_path = string(Path_stem, "Experiment/Heuristic_Solutions/", string(P), string(/), string(T), string(/), string(Scenario_num), "_", string(σ), "_", string(Sim_num), "_", string(N), "_", string(Time_limit), ".csv")
            Optimized_path = string(Path_stem, "Experiment/MIP_Solutions/",       string(P), string(/), string(T), string(/), string(Scenario_num), "_", string(σ), "_", string(Sim_num), "_", string(N), "_", string(Time_limit), ".csv")
            Heuristic_partitions = read_partitions(Heuristic_path, T)
            Optimized_partitions = read_partitions(Optimized_path, T)

            ### CALCULATE ESTIMATED POSITIONS & OBJECTIVE SCORE ###
            (Random_positions,    Random_objective)    = estimate_positions(Ideal_partitions, Random_partitions,    P, T)
            (Ideal_positions,     Ideal_objective)     = estimate_positions(Ideal_partitions, Ideal_partitions,     P, T)
            (Heuristic_positions, Heuristic_objective) = estimate_positions(Ideal_partitions, Heuristic_partitions, P, T)
            (Optimized_positions, Optimized_objective) = estimate_positions(Ideal_partitions, Optimized_partitions, P, T)

            ### SOLVE TRAJECTORY ASSIGNMENT MATCHING ###
            Ideal_assignments     = collect(1:P)
            Random_assignments    = solve_traj_assignment(True_positions, Random_positions,    P, T)
            Heuristic_assignments = solve_traj_assignment(True_positions, Heuristic_positions, P, T)
            Optimized_assignments = solve_traj_assignment(True_positions, Optimized_positions, P, T)

            ### CALCULATE ACCURACY ###
            Ideal_accuracy     = calc_accuracy(Ideal_partitions, Ideal_partitions,     Ideal_assignments,     P, T)
            Random_accuracy    = calc_accuracy(Ideal_partitions, Random_partitions,    Random_assignments,    P, T)
            Heuristic_accuracy = calc_accuracy(Ideal_partitions, Heuristic_partitions, Heuristic_assignments, P, T)
            Optimized_accuracy = calc_accuracy(Ideal_partitions, Optimized_partitions, Optimized_assignments, P, T)

            ### CALCULATE DELTA ###
            Random_δ     = calc_delta(True_positions, Random_positions,    Random_assignments,    P, T)
            Ideal_δ      = calc_delta(True_positions, Ideal_positions,     Ideal_assignments,     P, T)
            Heuristic_δ  = calc_delta(True_positions, Heuristic_positions, Heuristic_assignments, P, T)
            Optimized_δ  = calc_delta(True_positions, Optimized_positions, Optimized_assignments, P, T)

            ### WRITE RESULTS TO FILE ###
            if Scenario_num <= Num_parallel

              open(Accuracy_path, "a") do fp
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ1, ",", "Average",   ",", Random_accuracy,    ",", "Random",     ",", "Parallel")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ1, ",", "Average",   ",", Heuristic_accuracy, ",", "Heuristic",  ",", "Parallel")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ1, ",", "Average",   ",", Optimized_accuracy, ",", "Optimized",  ",", "Parallel")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ1, ",", "Average",   ",", Ideal_accuracy,     ",", "Ideal",      ",", "Parallel")
              end

              open(Accuracy_path, "a") do fp
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ2, ",", "Min",       ",", Random_accuracy,    ",", "Random",     ",", "Parallel")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ2, ",", "Min",       ",", Heuristic_accuracy, ",", "Heuristic",  ",", "Parallel")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ2, ",", "Min",       ",", Optimized_accuracy, ",", "Optimized",  ",", "Parallel")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ2, ",", "Min",       ",", Ideal_accuracy,     ",", "Ideal",      ",", "Parallel")
              end

              open(Accuracy_path, "a") do fp
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ3, ",", "Alpha_Min", ",", Random_accuracy,    ",", "Random",     ",", "Parallel")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ3, ",", "Alpha_Min", ",", Heuristic_accuracy, ",", "Heuristic",  ",", "Parallel")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ3, ",", "Alpha_Min", ",", Optimized_accuracy, ",", "Optimized",  ",", "Parallel")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ3, ",", "Alpha_Min", ",", Ideal_accuracy,     ",", "Ideal",      ",", "Parallel")
              end

              open(Accuracy_path, "a") do fp
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ4, ",", "Proximity", ",", Random_accuracy,    ",", "Random",     ",", "Parallel")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ4, ",", "Proximity", ",", Heuristic_accuracy, ",", "Heuristic",  ",", "Parallel")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ4, ",", "Proximity", ",", Optimized_accuracy, ",", "Optimized",  ",", "Parallel")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ4, ",", "Proximity", ",", Ideal_accuracy,     ",", "Ideal",      ",", "Parallel")
              end

              open(Delta_path, "a") do fp
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ1, ",", "Average",   ",", Random_δ,    ",", "Random",     ",", "Parallel")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ1, ",", "Average",   ",", Heuristic_δ, ",", "Heuristic",  ",", "Parallel")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ1, ",", "Average",   ",", Optimized_δ, ",", "Optimized",  ",", "Parallel")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ1, ",", "Average",   ",", Ideal_δ,     ",", "Ideal",      ",", "Parallel")
              end

              open(Delta_path, "a") do fp
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ2, ",", "Min",       ",", Random_δ,    ",", "Random",     ",", "Parallel")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ2, ",", "Min",       ",", Heuristic_δ, ",", "Heuristic",  ",", "Parallel")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ2, ",", "Min",       ",", Optimized_δ, ",", "Optimized",  ",", "Parallel")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ2, ",", "Min",       ",", Ideal_δ,     ",", "Ideal",      ",", "Parallel")
              end

              open(Delta_path, "a") do fp
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ3, ",", "Alpha_Min", ",", Random_δ,    ",", "Random",     ",", "Parallel")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ3, ",", "Alpha_Min", ",", Heuristic_δ, ",", "Heuristic",  ",", "Parallel")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ3, ",", "Alpha_Min", ",", Optimized_δ, ",", "Optimized",  ",", "Parallel")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ3, ",", "Alpha_Min", ",", Ideal_δ,     ",", "Ideal",      ",", "Parallel")
              end

              open(Delta_path, "a") do fp
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ4, ",", "Proximity", ",", Random_δ,    ",", "Random",     ",", "Parallel")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ4, ",", "Proximity", ",", Heuristic_δ, ",", "Heuristic",  ",", "Parallel")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ4, ",", "Proximity", ",", Optimized_δ, ",", "Optimized",  ",", "Parallel")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ4, ",", "Proximity", ",", Ideal_δ,     ",", "Ideal",      ",", "Parallel")
              end

              open(Objective_path, "a") do fp
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ1, ",", "Average",   ",", Random_objective,    ",", "Random",     ",", "Parallel")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ1, ",", "Average",   ",", Heuristic_objective, ",", "Heuristic",  ",", "Parallel")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ1, ",", "Average",   ",", Optimized_objective, ",", "Optimized",  ",", "Parallel")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ1, ",", "Average",   ",", Ideal_objective,     ",", "Ideal",      ",", "Parallel")
              end

              open(Objective_path, "a") do fp
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ2, ",", "Min",       ",", Random_objective,    ",", "Random",     ",", "Parallel")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ2, ",", "Min",       ",", Heuristic_objective, ",", "Heuristic",  ",", "Parallel")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ2, ",", "Min",       ",", Optimized_objective, ",", "Optimized",  ",", "Parallel")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ2, ",", "Min",       ",", Ideal_objective,     ",", "Ideal",      ",", "Parallel")
              end

              open(Objective_path, "a") do fp
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ3, ",", "Alpha_Min", ",", Random_objective,    ",", "Random",     ",", "Parallel")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ3, ",", "Alpha_Min", ",", Heuristic_objective, ",", "Heuristic",  ",", "Parallel")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ3, ",", "Alpha_Min", ",", Optimized_objective, ",", "Optimized",  ",", "Parallel")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ3, ",", "Alpha_Min", ",", Ideal_objective,     ",", "Ideal",      ",", "Parallel")
              end

              open(Objective_path, "a") do fp
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ4, ",", "Proximity", ",", Random_objective,    ",", "Random",     ",", "Parallel")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ4, ",", "Proximity", ",", Heuristic_objective, ",", "Heuristic",  ",", "Parallel")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ4, ",", "Proximity", ",", Optimized_objective, ",", "Optimized",  ",", "Parallel")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ4, ",", "Proximity", ",", Ideal_objective,     ",", "Ideal",      ",", "Parallel")
              end

            else

              open(Accuracy_path, "a") do fp
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ1, ",", "Average",   ",", Random_accuracy,    ",", "Random",     ",", "Crossing")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ1, ",", "Average",   ",", Heuristic_accuracy, ",", "Heuristic",  ",", "Crossing")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ1, ",", "Average",   ",", Optimized_accuracy, ",", "Optimized",  ",", "Crossing")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ1, ",", "Average",   ",", Ideal_accuracy,     ",", "Ideal",      ",", "Crossing")
              end

              open(Accuracy_path, "a") do fp
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ2, ",", "Min",       ",", Random_accuracy,    ",", "Random",     ",", "Crossing")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ2, ",", "Min",       ",", Heuristic_accuracy, ",", "Heuristic",  ",", "Crossing")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ2, ",", "Min",       ",", Optimized_accuracy, ",", "Optimized",  ",", "Crossing")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ2, ",", "Min",       ",", Ideal_accuracy,     ",", "Ideal",      ",", "Crossing")
              end

              open(Accuracy_path, "a") do fp
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ3, ",", "Alpha_Min", ",", Random_accuracy,    ",", "Random",     ",", "Crossing")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ3, ",", "Alpha_Min", ",", Heuristic_accuracy, ",", "Heuristic",  ",", "Crossing")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ3, ",", "Alpha_Min", ",", Optimized_accuracy, ",", "Optimized",  ",", "Crossing")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ3, ",", "Alpha_Min", ",", Ideal_accuracy,     ",", "Ideal",      ",", "Crossing")
              end

              open(Accuracy_path, "a") do fp
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ4, ",", "Proximity", ",", Random_accuracy,    ",", "Random",     ",", "Crossing")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ4, ",", "Proximity", ",", Heuristic_accuracy, ",", "Heuristic",  ",", "Crossing")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ4, ",", "Proximity", ",", Optimized_accuracy, ",", "Optimized",  ",", "Crossing")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ4, ",", "Proximity", ",", Ideal_accuracy,     ",", "Ideal",      ",", "Crossing")
              end

              open(Delta_path, "a") do fp
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ1, ",", "Average",   ",", Random_δ,    ",", "Random",     ",", "Crossing")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ1, ",", "Average",   ",", Heuristic_δ, ",", "Heuristic",  ",", "Crossing")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ1, ",", "Average",   ",", Optimized_δ, ",", "Optimized",  ",", "Crossing")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ1, ",", "Average",   ",", Ideal_δ,     ",", "Ideal",      ",", "Crossing")
              end
              
              open(Delta_path, "a") do fp
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ2, ",", "Min",       ",", Random_δ,    ",", "Random",     ",", "Crossing")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ2, ",", "Min",       ",", Heuristic_δ, ",", "Heuristic",  ",", "Crossing")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ2, ",", "Min",       ",", Optimized_δ, ",", "Optimized",  ",", "Crossing")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ2, ",", "Min",       ",", Ideal_δ,     ",", "Ideal",      ",", "Crossing")
              end

              open(Delta_path, "a") do fp
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ3, ",", "Alpha_Min", ",", Random_δ,    ",", "Random",     ",", "Crossing")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ3, ",", "Alpha_Min", ",", Heuristic_δ, ",", "Heuristic",  ",", "Crossing")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ3, ",", "Alpha_Min", ",", Optimized_δ, ",", "Optimized",  ",", "Crossing")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ3, ",", "Alpha_Min", ",", Ideal_δ,     ",", "Ideal",      ",", "Crossing")
              end

              open(Delta_path, "a") do fp
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ4, ",", "Proximity", ",", Random_δ,    ",", "Random",     ",", "Crossing")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ4, ",", "Proximity", ",", Heuristic_δ, ",", "Heuristic",  ",", "Crossing")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ4, ",", "Proximity", ",", Optimized_δ, ",", "Optimized",  ",", "Crossing")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ4, ",", "Proximity", ",", Ideal_δ,     ",", "Ideal",      ",", "Crossing")
              end

              open(Objective_path, "a") do fp
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ1, ",", "Average",   ",", Random_objective,    ",", "Random",     ",", "Crossing")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ1, ",", "Average",   ",", Heuristic_objective, ",", "Heuristic",  ",", "Crossing")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ1, ",", "Average",   ",", Optimized_objective, ",", "Optimized",  ",", "Crossing")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ1, ",", "Average",   ",", Ideal_objective,     ",", "Ideal",      ",", "Crossing")
              end

              open(Objective_path, "a") do fp
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ2, ",", "Min",       ",", Random_objective,    ",", "Random",     ",", "Crossing")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ2, ",", "Min",       ",", Heuristic_objective, ",", "Heuristic",  ",", "Crossing")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ2, ",", "Min",       ",", Optimized_objective, ",", "Optimized",  ",", "Crossing")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ2, ",", "Min",       ",", Ideal_objective,     ",", "Ideal",      ",", "Crossing")
              end

              open(Objective_path, "a") do fp
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ3, ",", "Alpha_Min", ",", Random_objective,    ",", "Random",     ",", "Crossing")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ3, ",", "Alpha_Min", ",", Heuristic_objective, ",", "Heuristic",  ",", "Crossing")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ3, ",", "Alpha_Min", ",", Optimized_objective, ",", "Optimized",  ",", "Crossing")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ3, ",", "Alpha_Min", ",", Ideal_objective,     ",", "Ideal",      ",", "Crossing")
              end

              open(Objective_path, "a") do fp
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ4, ",", "Proximity", ",", Random_objective,    ",", "Random",     ",", "Crossing")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ4, ",", "Proximity", ",", Heuristic_objective, ",", "Heuristic",  ",", "Crossing")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ4, ",", "Proximity", ",", Optimized_objective, ",", "Optimized",  ",", "Crossing")
                println(fp, P, ",", T, ",", Scenario_num, ",", σ, ",", Sim_num, ",", N, ",", Time_limit, ",", ρ4, ",", "Proximity", ",", Ideal_objective,     ",", "Ideal",      ",", "Crossing")
              end 

            end

            ### WRITE ESTIMATED POSITIONS TO FILE ###
            Ideal_write_path     = string(Path_stem, "R_Files/Ideal_Positions/",     string(P), string(/), string(T), string(/), string(Scenario_num), "_", string(σ), "_", string(Sim_num), "_", string(N), "_", string(Time_limit), ".csv")
            Heuristic_write_path = string(Path_stem, "R_Files/Heuristic_Positions/", string(P), string(/), string(T), string(/), string(Scenario_num), "_", string(σ), "_", string(Sim_num), "_", string(N), "_", string(Time_limit), ".csv")
            Optimized_write_path = string(Path_stem, "R_Files/MIO_Positions/",       string(P), string(/), string(T), string(/), string(Scenario_num), "_", string(σ), "_", string(Sim_num), "_", string(N), "_", string(Time_limit), ".csv")
            write_positions(Ideal_positions,     Ideal_assignments,     Ideal_write_path,     P, T)
            write_positions(Heuristic_positions, Heuristic_assignments, Heuristic_write_path, P, T)
            write_positions(Optimized_positions, Optimized_assignments, Optimized_write_path, P, T)
            
            ### WRITE ASSIGNED PARTITIONS TO FILE ###
            Ideal_write_Path     = string(Path_stem, "R_Files/Ideal_Associations/",     string(P), string(/), string(T), string(/), string(Scenario_num), "_", string(σ), "_", string(Sim_num), "_", string(N), "_", string(Time_limit), ".csv") 
            Heuristic_write_path = string(Path_stem, "R_Files/Heuristic_Associations/", string(P), string(/), string(T), string(/), string(Scenario_num), "_", string(σ), "_", string(Sim_num), "_", string(N), "_", string(Time_limit), ".csv")
            Optimized_write_path = string(Path_stem, "R_Files/MIO_Associations/",       string(P), string(/), string(T), string(/), string(Scenario_num), "_", string(σ), "_", string(Sim_num), "_", string(N), "_", string(Time_limit), ".csv")
            write_positions(Ideal_partitions,     Ideal_assignments,     Ideal_write_Path,     P, T)
            write_positions(Heuristic_partitions, Heuristic_assignments, Heuristic_write_path, P, T)
            write_positions(Optimized_partitions, Optimized_assignments, Optimized_write_path, P, T)

            end # MIP_Times
          end # N_range
        end # Sim_range
      end # σ_range
    end # Scenario_range
  end # T_range
end # P_range