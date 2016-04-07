#### CHANGE TO LOCAL GIT DIRECTORY ###
const Path_stem = "/Users/za25454/Documents/Academic/Research/Git/Multi-Target-Tracking/Julia/Basic/"

### LOAD REQUIRED FUNCTIONS/SCRIPTS ###
include(string(Path_stem, "Functions/Miscellaneous/Read_Partitions.jl"))
include(string(Path_stem, "Functions/Miscellaneous/Write_Partitions.jl"))

include(string(Path_stem, "Functions/Scenario/Assemble_Detections.jl"))
include(string(Path_stem, "Functions/Scenario/Shuffle_Detections.jl"))


#####################################################
###    STEP 0: DEFINE EXPERIMENTAL PARAMETERS    ####
#####################################################

const P              = parse(Int, ARGS[1])       # Number of targets
const T              = parse(Int, ARGS[2])       # Number of time steps
 
const Scenario_num   = parse(Int, ARGS[3])       # Scenario number
const Sim_num        = parse(Int, ARGS[4])       # Simulation number

const σ_1              = 0.1                # 1st noise parameter value
const σ_2              = 0.5                # 2nd noise parameter value
const σ_3              = 1.0                # 3rd noise parameter value
const σ_4              = 2.0                # 4th noise parameter value
const σ_5              = 3.5                # 4th noise parameter value
const σ_6              = 5.0                # 4th noise parameter value

### CONSTRUCT RANGES ###
σ_range         = Float64[σ_1, σ_2, σ_3, σ_4, σ_5, σ_6] # Range of noise parameters

#######################################################
###    STEP 3: GENERATE SIMULATED RADAR DATA    ####
#######################################################

### READ IN TRUE POSITION DATA ###
Position_path = string(Path_stem, "Experiment/True_Positions/", string(P), "_", string(T), "_", string(Scenario_num), ".csv")
True_position = read_partitions(Position_path, T)

for σ in σ_range

  ### PRINT PROGRESS TO SCREEN
  println("Assembling detections for ", string(P), "x", string(T), " Scenario #: ", string(Scenario_num), ", σ: ", string(σ), ", Sim #: ", string(Sim_num))

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

end # σ_range