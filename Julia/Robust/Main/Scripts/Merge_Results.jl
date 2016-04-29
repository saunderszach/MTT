using DataFrames

#### CHANGE TO LOCAL GIT DIRECTORY ###
const Path_stem = "/home/gridsan/ZA25454/Robust/Results/"

#####################################################
###    STEP 0: DEFINE EXPERIMENTAL PARAMETERS    ####
#####################################################

const P_min             = 4                        # Minimum of target range
const P_step            = 2                        # Step size of target range
const P_max             = 10                       # Maximum of target range

const T_min             = 4                        # Minimum of time range
const T_step            = 2                        # Step size of time range
const T_max             = 10                       # Maximum of time range

const Num_parallel      = 10                       # Number of scenarios to generate using "parallel" method
const Num_crossing      = 10                       # Number of scenarios to generate using "crossing" method

const σ_1               = 0.1                      # 1st noise parameter value
const σ_2               = 0.5                      # 2nd noise parameter value
const σ_3               = 1.0                      # 3rd noise parameter value
const σ_4               = 2.0                      # 4th noise parameter value

const γ_min             = 0.80                     # Minimum missed detection probability
const γ_step            = 0.05                     # Missed detection probability step size
const γ_max             = 0.95                     # Maximum missed detection probability

const λ_1               = 0.1                      # 1st false alarm rate
const λ_2               = 0.5                      # 2nd false alarm rate
const λ_3               = 1.0                      # 3rd false alarm rate
const λ_4               = 2.0                      # 4th false alarm rate

const Sim_min           = 1                        # Starting range of perturbations
const Sim_max           = 10                       # Ending range of perturbations 

const Grid_size         = 10                       # Size of window for targets to exist within
const MIP_seed          = 5271992                  # Set gurobi seed
const Num_threads       = 1                        # Set gurobi thread limit

Num_scenarios = Num_parallel + Num_crossing        # Number of total scenarios to generate

### CONSTRUCT RANGES ###
P_range           = collect(P_min:P_step:P_max)    # Range of targets 
T_range           = collect(T_min:T_step:T_max)    # Range of time steps
Scenario_range    = collect(1:1:Num_scenarios)     # Range of scenarios
σ_range           = Float64[σ_1, σ_2, σ_3, σ_4]    # Range of scenaro noise
γ_range           = collect(γ_min:γ_step:γ_max)    # Range of missed detection probabilities
λ_range           = Float64[λ_1, λ_2, λ_3, λ_4]    # Range of false alarm rates
Sim_range         = collect(Sim_min:1:Sim_max)     # Range of simulations

Write_path = string(Path_stem, "Files/Results_summary.csv")
open(Write_path,"w") do fp
	println(fp, "P,T,Scenario_num,Sigma,Gamma,Lambda,Sim_num,Theta,Phi,Test_P,MIO_Time,Rho,Accuracy,Delta,Objective,Solution_Type,Scenario_Type")
end


for P in P_range
  for T in T_range
    for Scenario_num in Scenario_range
      for σ in σ_range
      	for γ in γ_range
  		    for λ in λ_range

  		  	  Read_path = string(Path_stem, "Results_Summaries/", string(P), "_", 
  		  											                                  string(T), "_", 
  		  											                                  string(Scenario_num), "_",
  		  									                                      string(σ), "_", 
  		  											                                  string(γ), "_", 
  		  											                                  string(λ), ".csv")
  		  	  df = readcsv(Read_path)
  		  	
			      open(Write_path,"a") do fp
				      writecsv(fp, df[2:end,:])
			      end

		     end # λ_range
		   end # γ_range
      end # σ_range
    end # Scenario_range
  end # T_range
end # P_range