#### CHANGE TO LOCAL GIT DIRECTORY ###
const Path_stem = "/home/gridsan/ZA25454/"

#####################################################
###    STEP 0: DEFINE EXPERIMENTAL PARAMETERS    ####
#####################################################

const P_min             = 4                 # Minimum of target range
const P_step            = 2                 # Step size of target range
const P_max             = 10                # Maximum of target range

const T_min             = 4                 # Minimum of time range
const T_step            = 2                 # Step size of time range
const T_max             = 10                # Maximum of time range

const Scenario_min     = 1                  # Starting range of scenario numbers
const Scenario_max     = 20                 # Ending range of scenario numbers

const Sim_min          = 1                  # Starting range of simulation numbers
const Sim_max          = 10                 # Ending range of simulation numbers 

### CONSTRUCT RANGES ###
P_range           = collect(P_min:P_step:P_max)               # Range of targets 
T_range           = collect(T_min:T_step:T_max)               # Range of time steps
Scenario_range    = collect(Scenario_min:1:Scenario_max)      # Range of scenarios
Sim_range         = collect(Sim_min:1:Sim_max)                # Range of simulations

Write_path = string(Path_stem, "Batch_Single_Data.sh")
open(Write_path,"w") do fp
end

for P in P_range

  ### Define range of noise parameters
  if P <= 6
    σ_range = Float64[0.5, 1.0, 2.5, 5.0]     # Range of scenaro noise
  else
    σ_range = Float64[1.0, 2.0, 5.0, 10.0]    # Range of scenaro noise
  end

  for T in T_range
    for Scenario_num in Scenario_range
      for Sim_num in Sim_range
        for σ in σ_range

        	try
	            Test_path = string(Path_stem, "Experiment/Data/", string(P), "_", string(T), "_", string(Scenario_num), "_", string(Sim_num), "_", string(σ), ".csv")
	            readcsv(Test_path)
            catch
      				open(Write_path, "a") do fp
      					println(fp, "qsub -N julia -o Logs/Data_", string(P), "_",
      							string(T), "_", string(Scenario_num), "_", string(Sim_num), ".txt", " ",
      							"/home/gridsan/ZA25454/Wrappers/Data_wrapper.sh ", string(P), " ", string(T), " ", 
      							string(Scenario_num), " ", string(Sim_num))
      				end
            end

       	end # σ_range
      end # Sim_range
    end # Scenario_range
  end # T_range
end # P_range