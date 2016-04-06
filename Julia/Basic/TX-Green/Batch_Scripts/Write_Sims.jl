#### CHANGE TO LOCAL GIT DIRECTORY ###
#const Path_stem = "/home/gridsan/ZA25454/"
const Path_stem = "/Users/za25454/Desktop/"

#####################################################
###    STEP 0: DEFINE EXPERIMENTAL PARAMETERS    ####
#####################################################

const P_min             = 4                 # Minimum of target range
const P_step            = 2                 # Step size of target range
const P_max             = 10                # Maximum of target range

const T_min             = 4                 # Minimum of time range
const T_step            = 2                 # Step size of time range
const T_max             = 10                # Maximum of time range

const Scenario_min      = 1                 # Starting range of scenario numbers
const Scenario_max      = 20                # Ending range of scenario numbers

const Sim_min           = 1                 # Starting range of simulations
const Sim_max           = 10                # Ending range of simulations

### CONSTRUCT RANGES ###
P_range           = collect(P_min:P_step:P_max)               # Range of targets 
T_range           = collect(T_min:T_step:T_max)               # Range of time steps
Scenario_range    = collect(Scenario_min:1:Scenario_max)      # Range of scenarios
Sim_range         = collect(Sim_min:1:Sim_max)                # Range of simulations


Write_path = string(Path_stem, "Batch_Run_Sims.sh")
open(Write_path,"w") do fp
end

for P in P_range
  for T in T_range
    for Scenario_num in Scenario_range
      for Sim_num in Sim_range

		open(Write_path, "a") do fp
			println(fp, "qsub -N julia -o Logs/Sim_", string(P), "_",
					string(T), "_", string(Scenario_num), "_", string(Sim_num), ".txt", " ",
					"/home/gridsan/ZA25454/Wrappers/Sims_wrapper.sh ", string(P), " ", string(T), " ", 
					string(Scenario_num), " ", string(Sim_num))
		end

      end # Sim_range
    end # Scenario_range
  end # T_range
end # P_range
