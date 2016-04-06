using Distributions

#### CHANGE TO LOCAL GIT DIRECTORY ###
const Path_stem = "/Users/za25454/Documents/Academic/Research/Git/Multi-Target-Tracking/Julia/Robust/"

### LOAD REQUIRED FUNCTIONS/SCRIPTS ###
include(string(Path_stem, "Functions/Miscellaneous/Read_Partitions.jl"))
include(string(Path_stem, "Functions/Miscellaneous/Write_Partitions.jl"))
include(string(Path_stem, "Functions/Miscellaneous/Create_Exp_Directories.jl"))

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

const γ_min            = 0.8                # Minimum missed detection probability
const γ_step           = 0.5                # Missed detection probability step size
const γ_max            = 1.0                # Maximum missed detection probability

const λ_min            = 0.5                # Minimum false alarm rate
const λ_step           = 0.5                # Missed false alarm rate step size
const λ_max            = 1.0                # Maximum false alarm rate

const Sim_min          = 1                  # Starting range of simulation numbers
const Sim_max          = 10                 # Ending range of simulation numbers 

### CONSTRUCT RANGES ###
P_range           = collect(P_min:P_step:P_max)               # Range of targets 
T_range           = collect(T_min:T_step:T_max)               # Range of time steps
Scenario_range    = collect(Scenario_min:1:Scenario_max)      # Range of scenarios
γ_range           = collect(γ_min:γ_step:γ_max)               # Range of missed detection probabilities
λ_range           = collect(λ_min:λ_step:λ_max)               # Range of false alarm rates
Sim_range         = collect(Sim_min:1:Sim_max)                # Range of simulations

### CREATE REQUIRED DIRECTORIES ###
create_directories(Path_stem, P_range, T_range)

#######################################################
###    STEP 3: GENERATE SIMULATED RADAR DATA    ####
#######################################################

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
    for Scenario_num in Scenario_range

      ### PRINT PROGRESS TO SCREEN
      println("Assembling detections for ", string(P), "x", string(T),  " Scenario #: ", string(Scenario_num))

      ### READ IN TRUE POSITION DATA ###
      Position_path = string(Path_stem, "Experiment/True_Positions/", string(P), "_", string(T), "_", string(Scenario_num), ".csv")
      True_position = read_partitions(Position_path, T)

      for σ in σ_range
          
        ### ASSEMBLE DETECTIONS ###
        Original_detections = assemble_detections(True_position, P, T, σ)

        ### WRITE ORIGINAL DETECTIONS TO FILE ###
        Original_path  = string(Path_stem, "Experiment/Detections/", string(P), string(/), string(T), string(/), string(Scenario_num), "_", string(σ), ".csv")
        write_partitions(Original_detections, Original_path, T)
          
        for γ in γ_range

          ### SET THE SEED  ###
          srand(convert(Int64, P + T*10 + Scenario_num*100 + σ*1000 + γ*10000))

          ### REMOVE MISSED DETECTIONS
          Missed_detections = remove_detections(Original_detections, P, T, γ)
            
          for λ in λ_range
            for Sim_num in Sim_range

              ### SET THE SEED  ###
              srand(convert(Int64, P + T*10 + Scenario_num*100 + σ*1000 + γ*10000 + λ*100000 + Sim_num*1000000))

              (Detections, False_alarms) = add_false_alarms(Missed_detections, Grid_size, T, λ)

              ### SET THE SEED  ###
              srand(convert(Int64, P + T*10 + Scenario_num*100 + σ*1000 + γ*10000 + λ*100000 + Sim_num*1000000))

              ### SHUFFLE DETECTIONS ###
              Data = shuffle_detections(Detections, T)

              ### DEFINE PATHS FOR DATA ###
              Data_path = string(Path_stem, "Experiment/Data/", string(P), string(/), string(T), string(/), string(Scenario_num), "_", string(σ), "_", string(γ), "_", string(λ), "_", string(Sim_num), ".csv")

              ### WRITE DATA TO FILE ###
              write_partitions(Data, Data_path, T)
    
            end # Sim_range
          end # λ_range
        end # γ_range
      end # σ_range
    end # Scenario_range
  end # T_range
end # P_range