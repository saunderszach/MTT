using Distributions, JuMP, Gurobi

#### CHANGE TO LOCAL GIT DIRECTORY ###
Path_stem = "/Users/za25454/Documents/Academic/Research/Git/Multi-Target-Tracking/"

### LOAD FUNCTIONS/SCRIPTS ###
include(string(Path_stem, "Julia/Data/Robust/Generate_Data_FA_MD.jl"))
include(string(Path_stem, "Julia/Functions/Calculate_Initial_Objective_Parameters.jl"))
include(string(Path_stem, "Julia/Functions/Update_Objective_Parameters.jl"))
include(string(Path_stem, "Julia/Heuristic/Functions/Robust/Robust_Heuristic_Swap_1.jl"))
include(string(Path_stem, "Julia/Heuristic/Functions/Robust/Run_Robust_Heuristic.jl"))
include(string(Path_stem, "Julia/Optimization/Robust/Robust_MIP.jl"))

### DEFINE PARAMETERS ###
P = 4        #P    - number of true targets (constant)
T = 5        #T    - number of time steps (known)
σ = 0.15     #σ    - Noise factor   (0.)
γ = 0.90     #γ    - Detection probability (0.7 to 1.0)
λ = 1        #λ    - False alarm rate (Lower)

### DEFINE PENALTIES ###
θ = 0.4    #θ    - penalty per False Alarm
ϕ = 0.20   #ϕ    - penatly per Missed Detection

### GENERATE SCENARIO DATA ###
#srand(123)

(Data, Big_M, Num_FA) = generate_data(P, T, σ, γ, λ)

##############################################################
### STEP 1: DETERMINE RANGE OF POSSIBLE NUMBER OF TARGETS  ###
##############################################################
Num_Detections = zeros(Int64,T)
Lengths = zeros(Int64,T)

for t = 1:T
  Num_Detections[t] = length(Data[t])
end

P_Min   = minimum(Num_Detections)
P_Max   = maximum(Num_Detections)
P_Range = collect(minimum(Num_Detections):maximum(Num_Detections))

### RUN HEURISTIC ###
Num_iterations = 3 #Number of starting points for heuristic
Start_time = time()

Objective_Scores = zeros(length(P_Range))
P_Data = cell(T)
Best_Data = cell(T)

count = 1
for p in P_Range

  for t = 1:T
    P_Data[t] = copy(Data[t])
  end

  for t = 1:T
    for i = 1:Num_Detections[t]
      push!(P_Data[t],-1000)
    end

    while length(P_Data[t]) < p
      push!(P_Data[t],-1000)
    end

    Lengths[t] = length(P_Data[t])
  end

  (Best_objective, Best_Data) = robust_heuristic_swap(p,T,P_Data, Num_Detections, Lengths, θ, ϕ)

  for i = 1:Num_iterations
    (Total_objective, New_Data) = robust_heuristic_swap(p,T,P_Data, Num_Detections, Lengths, θ, ϕ)
    if Total_objective < Best_objective
        Best_objective = Total_objective
      for t = 1:T
        Best_Data[t] = copy(New_Data[t])
      end
    end
  end

  Objective_Scores[count] = Best_objective
  count = count + 1

end

Run_time = time() - Start_time

### PRINT SCENARIO INFORMATION ###
println("Summary of scenario parameters:")
println("# Targets(true):",P)
println("# TimeSteps:\t", T)
println("Noise (σ):\t", σ)
println("MD Rate (γ):\t",γ)
println("FA Rate (λ):\t",λ)

println("\nSummary of Generated Scenario Data")
println("Min # Detections:\t", P_Min)
println("Max # Detections:\t", P_Max)

### PRINT PENALTY INFORMATION ###
println("\nSummary of heuristic parameters:")
println("FA Penalty (θ): ", θ)
println("MD Penalty (ϕ): ", ϕ)

### PRINT SUMMARY OF HEURISTIC RESULTS ###
(Heuristic_objective,min_index) = findmin(Objective_Scores)
println("\nSummary of Heuristic Results:")
println("Est # Targets:\t", P_Range[min_index])
println("Obj Score:\t", round(Heuristic_objective,6))
println("Run Time:\t", Run_time)

