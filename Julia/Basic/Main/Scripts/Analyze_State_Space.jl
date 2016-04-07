using StatsBase

#### CHANGE TO LOCAL GIT DIRECTORY ###
const Path_stem = "/Users/za25454/Documents/Academic/Research/Git/Multi-Target-Tracking/Julia/Basic/"

### LOAD REQUIRED FUNCTIONS/SCRIPTS ###
include(string(Path_stem, "Functions/Miscellaneous/Read_Partitions.jl"))
include(string(Path_stem, "Functions/Scenario/Calculate_Density.jl"))

#####################################################
###    STEP 0: DEFINE EXPERIMENTAL PARAMETERS    ####
#####################################################

const P_min            = 4                    # Minimum of target range
const P_step           = 2                    # Step size of target range
const P_max            = 10                   # Maximum of target range

const T_min            = 4                    # Minimum of time range
const T_step           = 2                    # Step size of time range
const T_max            = 10                   # Maximum of time range

const Num_parallel     = 10                   # Number of scenarios to generate using "parallel" method
const Num_crossing     = 10                   # Number of scenarios to generate using "crossing" method

const σ_1              = 0.1                  # 1st noise parameter value
const σ_2              = 0.5                  # 2nd noise parameter value
const σ_3              = 1.0                  # 3rd noise parameter value
const σ_4              = 2.0                  # 4th noise parameter value
const σ_5              = 3.5                  # 4th noise parameter value
const σ_6              = 5.0                  # 4th noise parameter value

Num_scenarios = Num_parallel + Num_crossing   # Number of total scenarios to generate

### CONSTRUCT RANGES ###
P_range         = collect(P_min:P_step:P_max) # Range of targets 
T_range         = collect(T_min:T_step:T_max) # Range of time steps
Scenario_range  = collect(1:1:Num_scenarios)  # Range of scenarios
σ_range         = Float64[σ_1, σ_2, σ_3, σ_4, σ_5, σ_6] # Range of noise parameters


### CREATE REQUIRED DIRECTORIES ###
mypath = string(Path_stem, "Results")
isdir(mypath) || mkdir(mypath)

### CREATE REQUIRED DIRECTORIES ###
mypath = string(Path_stem, "Results/Files")
isdir(mypath) || mkdir(mypath)


#################################################
###    STEP 1A: ANALYZE SIMULATION RESULTS    ###
#################################################
Write_path = string(Path_stem, "Results/Files/State_Space.csv")
open(Write_path,"w") do fp
  println(fp, "P,T,Sigma,Rho,Rho_Type,Scenario_Type")
end

for P in P_range
  for T in T_range
    println("Evaluating scenarios of size: ", P, "x", T)
    for Scenario_num in Scenario_range
      for σ in σ_range

        Position_path = string(Path_stem, "Experiment/True_Positions/", string(P), "_", string(T), "_", string(Scenario_num), ".csv")
        True_position = read_partitions(Position_path, T)

        (ρ1, ρ2, ρ3, ρ4) = calc_density(True_position, P, T, σ)
        
        if Scenario_num <=  Num_parallel
          open(Write_path,"a") do fp
            println(fp, P, ",", T, ",", σ, ",", ρ1, ",", "Average",   ",", "Parallel")
            println(fp, P, ",", T, ",", σ, ",", ρ2, ",", "Min",       ",", "Parallel")
            println(fp, P, ",", T, ",", σ, ",", ρ3, ",", "Alpha_Min", ",", "Parallel")
            println(fp, P, ",", T, ",", σ, ",", ρ4, ",", "Proximity", ",", "Parallel")
          end
        else
          open(Write_path,"a") do fp
            println(fp, P, ",", T, ",", σ, ",", ρ1, ",", "Average",   ",", "Crossing")
            println(fp, P, ",", T, ",", σ, ",", ρ2, ",", "Min",       ",", "Crossing")
            println(fp, P, ",", T, ",", σ, ",", ρ3, ",", "Alpha_Min", ",", "Crossing")
            println(fp, P, ",", T, ",", σ, ",", ρ4, ",", "Proximity", ",", "Crossing")
          end
        end

      end # σ_range
    end # Scenario_range
  end # T_range
end # P_range
