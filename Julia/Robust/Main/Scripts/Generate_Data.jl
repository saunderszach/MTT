using Distributions

#### CHANGE TO LOCAL GIT DIRECTORY ###
const Path_stem = "/Users/za25454/Documents/Academic/Research/Git/Multi-Target-Tracking/Julia/Robust/"

### LOAD REQUIRED FUNCTIONS/SCRIPTS ###
include(string(Path_stem, "Functions/Miscellaneous/Read_Partitions.jl"))
include(string(Path_stem, "Functions/Miscellaneous/Write_Partitions.jl"))
include(string(Path_stem, "Functions/Miscellaneous/Create_Directories.jl"))

include(string(Path_stem, "Functions/Scenario/Assemble_Detections.jl"))
include(string(Path_stem, "Functions/Scenario/Remove_Detections.jl"))
include(string(Path_stem, "Functions/Scenario/Add_False_Alarms.jl"))
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

const σ_1              = 0.1                # 1st noise parameter value
const σ_2              = 0.5                # 2nd noise parameter value
const σ_3              = 1.0                # 3rd noise parameter value
const σ_4              = 2.0                # 4th noise parameter value

const γ_min            = 0.80               # Minimum missed detection probability
const γ_step           = 0.05               # Missed detection probability step size
const γ_max            = 0.95               # Maximum missed detection probability

const λ_1              = 0.1                # 1st false alarm rate
const λ_2              = 0.5                # 2nd false alarm rate
const λ_3              = 1.0                # 3rd false alarm rate
const λ_4              = 2.0                # 4th false alarm rate

const Sim_min          = 1                  # Starting range of simulation numbers
const Sim_max          = 10                 # Ending range of simulation numbers 

const Grid_size        = 10                 # Size of window for targets to exist within

### CONSTRUCT RANGES ###
P_range           = collect(P_min:P_step:P_max)               # Range of targets 
T_range           = collect(T_min:T_step:T_max)               # Range of time steps
Scenario_range    = collect(Scenario_min:1:Scenario_max)      # Range of scenarios
σ_range           = Float64[σ_1, σ_2, σ_3, σ_4]               # Range of scenaro noise
γ_range           = collect(γ_min:γ_step:γ_max)               # Range of missed detection probabilities
λ_range           = Float64[λ_1, λ_2, λ_3, λ_4]               # Range of false alarm rates
Sim_range         = collect(Sim_min:1:Sim_max)                # Range of simulations

### CREATE REQUIRED DIRECTORIES ###
create_directories(Path_stem, P_range, T_range, Scenario_range, σ_range)

#######################################################
###    STEP 3: GENERATE SIMULATED RADAR DATA    ####
#######################################################

for P in P_range
  for T in T_range
    for Scenario_num in Scenario_range

      ### PRINT PROGRESS TO SCREEN
      println("Assembling detections for ", string(P), "x", string(T),  " Scenario #: ", string(Scenario_num))

      ### READ IN TRUE POSITION DATA ###
      Position_path = string(Path_stem, "Experiment/True_Positions/", string(P), "_", string(T), "_", string(Scenario_num), ".csv")
      True_position = read_partitions(Position_path)

      for σ in σ_range
        for γ in γ_range
          for λ in λ_range
            for Sim_num in Sim_range

              ### SET THE SEED  ###
              srand(convert(Int64, P + T*10 + Scenario_num*100 + σ*1000 + γ*10000 + λ*100000 + Sim_num*1000000))

              ### ASSEMBLE DETECTIONS ###
              Original_detections = assemble_detections(True_position, P, T, σ)

              ### REMOVE MISSED DETECTIONS ###
              (Data_MD, MD_key) = remove_detections(Original_detections, P, T, γ)

              ### ADD FALSE ALARMS ###
              (Unshuffled_data, Data_key) = add_false_alarms(Data_MD, MD_key, Grid_size, T, λ) 

              ### SHUFFLE DETECTIONS ###
              Data = shuffle_detections(Unshuffled_data, T)

              ### DEFINE PATHS FOR WRITING DATA ###
              #Original_path   = string(Path_stem, "Experiment/Original_Detections/", string(P), string(/), string(T), string(/), string(Scenario_num), "_", string(σ), "_", string(γ), "_", string(λ), "_", string(Sim_num), ".csv")
              #Unshuffled_path = string(Path_stem, "Experiment/Unshuffled_Data/",     string(P), string(/), string(T), string(/), string(Scenario_num), "_", string(σ), "_", string(γ), "_", string(λ), "_", string(Sim_num), ".csv")
              Data_key_path   = string(Path_stem, "Experiment/Data_Key/",            string(P), string(/), string(T), string(/), string(Scenario_num), "_", string(σ), "_", string(γ), "_", string(λ), "_", string(Sim_num), ".csv")
              Data_path       = string(Path_stem, "Experiment/Data/",                string(P), string(/), string(T), string(/), string(Scenario_num), "_", string(σ), "_", string(γ), "_", string(λ), "_", string(Sim_num), ".csv")

              ### WRITE DATA TO FILE ###
              #write_partitions(Original_detections, Original_path,   T)
              #write_partitions(Unshuffled_data,     Unshuffled_path, T)
              write_partitions(Data_key,            Data_key_path,   T)
              write_partitions(Data,                Data_path,       T)

            end # Sim_range
          end # λ_range
        end # γ_range
      end # σ_range
    end # Scenario_range
  end # T_range
end # P_range