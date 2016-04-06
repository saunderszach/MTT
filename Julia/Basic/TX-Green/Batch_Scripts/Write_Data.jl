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

const Num_scenarios     = 100                # Number of total scenarios
const Num_sims          = 30                 # Number of perturbations 

### CONSTRUCT RANGES ###
P_range           = collect(P_min:P_step:P_max)               # Range of targets 
T_range           = collect(T_min:T_step:T_max)               # Range of time steps
Scenario_range    = collect(1:1:Num_scenarios)                # Range of scenarios
Sim_range         = collect(1:1:Num_sims)                     # Range of perturbation sims


Write_path = string(Path_stem, "Batch_Make_Data.sh")
open(Write_path,"w") do fp
end

for P in P_range
  for T in T_range
    for Scenario_num in Scenario_range
      for Sim_num in Sim_range

		open(Write_path, "a") do fp
			println(fp, "qsub -N julia -o Logs/Data_", string(P), "_",
					string(T), "_", string(Scenario_num), "_", string(Sim_num), ".txt", " ",
					"/home/gridsan/ZA25454/Wrappers/Data_wrapper.sh ", string(P), " ", string(T), " ", 
					string(Scenario_num), " ", string(Sim_num))
		end

      end # Sim_range
    end # Scenario_range
  end # T_range
end # P_range