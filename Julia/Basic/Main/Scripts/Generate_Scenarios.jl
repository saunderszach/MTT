#### CHANGE TO LOCAL GIT DIRECTORY ###
const Path_stem = "/Users/za25454/Documents/Academic/Research/Git/Multi-Target-Tracking/Julia/Basic/"

### LOAD REQUIRED FUNCTIONS/SCRIPTS ###
include(string(Path_stem, "Functions/Miscellaneous/Write_Partitions.jl"))
include(string(Path_stem, "Functions/Scenario/Generate_Trajectories.jl"))
include(string(Path_stem, "Functions/Scenario/Simulate_Perturbations.jl"))


#####################################################
###    STEP 0: DEFINE EXPERIMENTAL PARAMETERS    ####
#####################################################

const P_min            = 4                  # Minimum of target range
const P_step           = 2                  # Step size of target range
const P_max            = 10                 # Maximum of target range

const T_min            = 4                  # Minimum of time range
const T_step           = 2                  # Step size of time range
const T_max            = 10                 # Maximum of time range

const Num_parallel     = 10                 # Number of scenarios to generate using "parallel" method
const Num_crossing     = 10                 # Number of scenarios to generate using "crossing" method

const Gap_size         = 0.5                # Gap size between targets
const Grid_size        = 10                 # Size of window for targets to exist within

const Parallel_grid_steps  = 5              # Grid step size for parallel scenarios
const Crossing_grid_steps  = 20             # Grid step size for crossing scenarios

Num_scenarios = Num_parallel + Num_crossing         # Number of total scenarios to generate

### CONSTRUCT RANGES ###
P_range           = collect(P_min:P_step:P_max)               # Range of targets 
T_range           = collect(T_min:T_step:T_max)               # Range of time steps
Parallel_range    = collect(1:1:Num_parallel)                 # Range of "parallel" scenarios
Crossing_range    = collect(Num_parallel+1:1:Num_scenarios)   # Range of "crossing" scenarios

### CREATE REQUIRED DIRECTORIES ###
mypath = string(Path_stem, "Experiment")
isdir(mypath) || mkdir(mypath)

mypath = string(Path_stem, "Experiment/True_Positions")
isdir(mypath) || mkdir(mypath)


#####################################################
###    STEP 1: GENERATE NEW TRUE TRAJECTORIES    ####
#####################################################
for P in P_range

  # Set the grid window size
  # if P <= 6
  #   Grid_size = 5
  # else
  #   Grid_size = 10
  # end

  for T in T_range
    for Scenario_num in Parallel_range

      ### PRINT PROGRESS TO SCREEN
      println("Building ", string(P), "x", string(T), " (parallel) scenario number: ", string(Scenario_num))

      ### SET THE SEED
      srand(P + T*10 + Scenario_num*100)

      ### GENERATE NEW TRAJECTORIES ###
      True_Positions = generate_trajectories(P, T, Grid_size, Parallel_grid_steps, Gap_size, "Parallel")

      ### WRITE TRAJECTORIES TO FILE ###
      Write_path = string(Path_stem, "Experiment/True_Positions/", string(P), "_", string(T), "_", string(Scenario_num), ".csv")
      write_partitions(True_Positions, Write_path, P, T)

    end # Parallel_range

    for Scenario_num in Crossing_range
      
      ### PRINT PROGRESS TO SCREEN
      println("Building ", string(P), "x", string(T), " (crossing) scenario number: ", string(Scenario_num))

      ### SET THE SEED
      srand(P + T*10 + Scenario_num*100)

      ### GENERATE NEW TRAJECTORIES ###
      True_Positions = generate_trajectories(P, T, Grid_size, Crossing_grid_steps, Gap_size, "Crossing")

      ### WRITE TRAJECTORIES TO FILE ###
      Write_path = string(Path_stem, "Experiment/True_Positions/", string(P), "_", string(T), "_", string(Scenario_num), ".csv")
      write_partitions(True_Positions, Write_path, P, T)

    end # Crossing_range
    
  end # T_range
end # P_range