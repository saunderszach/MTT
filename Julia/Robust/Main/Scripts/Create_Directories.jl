
#### CHANGE TO LOCAL GIT DIRECTORY ###
const Path_stem = "/home/gridsan/ZA25454/Robust/"

const P_min            = 4                  # Minimum of target range
const P_step           = 2                  # Step size of target range
const P_max            = 10                 # Maximum of target range

const T_min            = 4                  # Minimum of time range
const T_step           = 2                  # Step size of time range
const T_max            = 10                 # Maximum of time range

const Scenario_min     = 1                  # Starting range of scenario numbers
const Scenario_max     = 2                  # Ending range of scenario numbers 

const σ_1              = 0.1                # 1st noise parameter value
const σ_2              = 0.5                # 2nd noise parameter value
const σ_3              = 1.0                # 3rd noise parameter value
const σ_4              = 2.0                # 4th noise parameter value

### CONSTRUCT RANGES ###
P_range           = collect(P_min:P_step:P_max)               # Range of targets 
T_range           = collect(T_min:T_step:T_max)               # Range of time steps
Scenario_range    = collect(Scenario_min:1:Scenario_max)      # Range of scenarios
σ_range           = Float64[σ_1, σ_2, σ_3, σ_4]               # Range of scenaro noise


mypath = string(Path_stem, "Experiment/Data")
isdir(mypath) || mkdir(mypath)

mypath = string(Path_stem, "Experiment/Garbage")
isdir(mypath) || mkdir(mypath)

# mypath = string(Path_stem, "Experiment/Unshuffled_Data")
# isdir(mypath) || mkdir(mypath)

mypath = string(Path_stem, "Experiment/Data_Key")
isdir(mypath) || mkdir(mypath)

# mypath = string(Path_stem, "Experiment/Original_Detections")
# isdir(mypath) || mkdir(mypath)

mypath = string(Path_stem, "Experiment/MIP_Solutions")
isdir(mypath) || mkdir(mypath)

# mypath = string(Path_stem, "Experiment/MIP_Summaries")
# isdir(mypath) || mkdir(mypath)

mypath = string(Path_stem, "Experiment/Heuristic_Solutions")
isdir(mypath) || mkdir(mypath)

mypath = string(Path_stem, "Experiment/Simulation_Summaries")
isdir(mypath) || mkdir(mypath)

for P in P_range
    
  mypath = string(Path_stem, "Experiment/Data/", string(P))
  isdir(mypath) || mkdir(mypath)

  # mypath = string(Path_stem, "Experiment/Unshuffled_Data/", string(P))
  # isdir(mypath) || mkdir(mypath)

  mypath = string(Path_stem, "Experiment/Data_Key/", string(P))
  isdir(mypath) || mkdir(mypath)

  # mypath = string(Path_stem, "Experiment/Original_Detections/", string(P))
  # isdir(mypath) || mkdir(mypath)

  mypath = string(Path_stem, "Experiment/MIP_Solutions/", string(P))
  isdir(mypath) || mkdir(mypath)

  # mypath = string(Path_stem, "Experiment/MIP_Summaries/", string(P))
  # isdir(mypath) || mkdir(mypath)

  mypath = string(Path_stem, "Experiment/Heuristic_Solutions/", string(P))
  isdir(mypath) || mkdir(mypath)

  for T in T_range

    mypath = string(Path_stem, "Experiment/Data/", string(P), string(/), string(T))
    isdir(mypath) || mkdir(mypath)

    # mypath = string(Path_stem, "Experiment/Unshuffled_Data/", string(P), string(/), string(T))
    # isdir(mypath) || mkdir(mypath)

    mypath = string(Path_stem, "Experiment/Data_Key/", string(P), string(/), string(T))
    isdir(mypath) || mkdir(mypath)

    # mypath = string(Path_stem, "Experiment/Original_Detections/", string(P), string(/), string(T))
    # isdir(mypath) || mkdir(mypath)

    mypath = string(Path_stem, "Experiment/MIP_Solutions/", string(P), string(/), string(T))
    isdir(mypath) || mkdir(mypath)

    # mypath = string(Path_stem, "Experiment/MIP_Summaries/", string(P), string(/), string(T))
    # isdir(mypath) || mkdir(mypath)

    mypath = string(Path_stem, "Experiment/Heuristic_Solutions/", string(P), string(/), string(T))
    isdir(mypath) || mkdir(mypath)
      
    for Scenario_num in Scenario_range

      mypath = string(Path_stem, "Experiment/MIP_Solutions/", string(P), string(/), string(T), string(/), string(Scenario_num))
      isdir(mypath) || mkdir(mypath)

      # mypath = string(Path_stem, "Experiment/MIP_Summaries/", string(P), string(/), string(T), string(/), string(Scenario_num))
      # isdir(mypath) || mkdir(mypath)

      mypath = string(Path_stem, "Experiment/Heuristic_Solutions/", string(P), string(/), string(T), string(/), string(Scenario_num))
      isdir(mypath) || mkdir(mypath)

      for σ in σ_range

        mypath = string(Path_stem, "Experiment/MIP_Solutions/", string(P), string(/), string(T), string(/), string(Scenario_num), string(/), string(σ))
        isdir(mypath) || mkdir(mypath)

        # mypath = string(Path_stem, "Experiment/MIP_Summaries/", string(P), string(/), string(T), string(/), string(Scenario_num), string(/), string(σ))
        # isdir(mypath) || mkdir(mypath)

        mypath = string(Path_stem, "Experiment/Heuristic_Solutions/", string(P), string(/), string(T), string(/), string(Scenario_num), string(/), string(σ))
        isdir(mypath) || mkdir(mypath)

      end # σ_range 
    end # Scenario_range
  end # T_range
end # P_range

