using Distributions

#### CHANGE TO LOCAL GIT DIRECTORY ###
const Path_stem = "/Users/za25454/Documents/Academic/Research/Git/Multi-Target-Tracking/Julia/Basic/"

### LOAD REQUIRED FUNCTIONS/SCRIPTS ###
include(string(Path_stem, "Functions/Miscellaneous/Read_Partitions.jl"))
include(string(Path_stem, "Functions/Miscellaneous/Write_Partitions.jl"))
include(string(Path_stem, "Functions/Miscellaneous/Create_Exp_Directories.jl"))

include(string(Path_stem, "Functions/Scenario/Assemble_Detections.jl"))
include(string(Path_stem, "Functions/Scenario/Shuffle_Detections.jl"))


#####################################################
###    STEP 0: DEFINE EXPERIMENTAL PARAMETERS    ####
#####################################################

const P_min            = 4                  # Minimum of target range
const P_step           = 2                  # Step size of target range
const P_max            = 10                 # Maximum of target range

const T_min            = 4                  # Minimum of time range
const T_step           = 2                  # Step size of time range
const T_max            = 10                 # Maximum of time range

const Scenario_min     = 1                  # Starting range of scenario numbers
const Scenario_max     = 20                 # Ending range of scenario numbers

const Sim_min          = 1                  # Starting range of simulation numbers
const Sim_max          = 10                 # Ending range of simulation numbers  

### CONSTRUCT RANGES ###
P_range           = collect(P_min:P_step:P_max)               # Range of targets 
T_range           = collect(T_min:T_step:T_max)               # Range of time steps
Scenario_range    = collect(Scenario_min:1:Scenario_max)      # Range of scenarios
Sim_range         = collect(Sim_min:1:Sim_max)                # Range of simulations

### CREATE REQUIRED DIRECTORIES ###
create_directories(Path_stem, P_range, T_range)

#######################################################
###    STEP 3: GENERATE SIMULATED RADAR DATA    ####
#######################################################

for P in P_range

  ### Define range of noise parameters
  if P <= 6
    σ_range = Float64[0.5, 1.0, 2.5, 5.0]     # Range of scenaro noise
  else
    σ_range = Float64[1.0, 2.0, 5.0, 10.0]    # Range of scenaro noise
  end

  for T in T_range
    for Scenario_num in Scenario_range

      ### PRINT PROGRESS TO SCREEN
      println("Assembling detections for ", string(P), "x", string(T),  " Scenario #: ", string(Scenario_num))

      ### READ IN TRUE POSITION DATA ###
      Position_path = string(Path_stem, "Experiment/True_Positions/", string(P), "_", string(T), "_", string(Scenario_num), ".csv")
      True_position = read_partitions(Position_path, T)

      for σ in σ_range
        for Sim_num in Sim_range

          ### SET THE SEED  ###
          srand(convert(Int64, P + T*10 + Scenario_num*100 + σ*1000 + Sim_num*10000))

          ### ASSEMBLE DETECTIONS ###
          Detections = assemble_detections(True_position, P, T, σ)

          ### SHUFFLE DETECTIONS ###
          Data = shuffle_detections(Detections, T)

          ### WRITE BOTH DATA & DETECTIONS TO FILE ###
          Detection_path = string(Path_stem, "Experiment/Detections/", string(P), string(/), string(T), string(/), string(Scenario_num), "_", string(σ), "_", string(Sim_num), ".csv")
          Data_path      = string(Path_stem, "Experiment/Data/",       string(P), string(/), string(T), string(/), string(Scenario_num), "_", string(σ), "_", string(Sim_num), ".csv")
          
          write_partitions(Detections, Detection_path, P, T)
          write_partitions(Data, Data_path, P, T)

        end # Sim_range
      end # σ_range
    end # Scenario_range
  end # T_range
end # P_range