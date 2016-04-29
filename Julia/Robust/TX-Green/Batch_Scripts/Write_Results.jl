#### CHANGE TO LOCAL GIT DIRECTORY ###
const Path_stem = "/Users/za25454/Desktop/"
#const Path_stem = "/home/gridsan/ZA25454/Robust/"

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

const σ_1               = 0.1               # 1st noise parameter value
const σ_2               = 0.5               # 2nd noise parameter value
const σ_3               = 1.0               # 3rd noise parameter value
const σ_4               = 2.0               # 4th noise parameter value

const γ_min             = 0.80              # Minimum missed detection probability
const γ_step            = 0.05              # Missed detection probability step size
const γ_max             = 0.95              # Maximum missed detection probability

const λ_1               = 0.1               # 1st false alarm rate
const λ_2               = 0.5               # 2nd false alarm rate
const λ_3               = 1.0               # 3rd false alarm rate
const λ_4               = 2.0               # 4th false alarm rate

### CONSTRUCT RANGES ###
P_range           = collect(P_min:P_step:P_max)               # Range of targets 
T_range           = collect(T_min:T_step:T_max)               # Range of time steps
Scenario_range    = collect(Scenario_min:1:Scenario_max)      # Range of scenarios
σ_range           = Float64[σ_1, σ_2, σ_3, σ_4]               # Range of scenaro noise
γ_range           = collect(γ_min:γ_step:γ_max)               # Range of missed detection probabilities
λ_range           = Float64[λ_1, λ_2, λ_3, λ_4]               # Range of false alarm rates

Write_path = string(Path_stem, "Batch_Analyze_Results.sh")
	open(Write_path,"w") do fp
end

for P in P_range
  for T in T_range
    for Scenario_num in Scenario_range
      for σ in σ_range
      	for γ in γ_range
  		  for λ in λ_range

			open(Write_path, "a") do fp
			  println(fp, "qsub -N julia -o Robust/Logs/Results_", string(P), "_",
			  	string(T), "_", string(Scenario_num), "_", string(σ), "_", string(γ), "_", string(λ), ".txt", " ",
			  	"/home/gridsan/ZA25454/Robust/TX-Green/Wrappers/Results_wrapper.sh ", string(P), " ", string(T), " ",
			  	string(Scenario_num), " ", string(σ), " ", string(γ), " ", string(λ))
			end

		  end # λ_range
		end # γ_range
      end # σ_range
    end # Scenario_range
  end # T_range
end # P_range
