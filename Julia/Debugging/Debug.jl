using JuMP, Gurobi

include("Functions/All_Misc_Functions.jl")
include("Data/Build_Scenario.jl")
include("Data/Generate_Data.jl");
include("Heuristic/Functions/Heuristic_Swap.jl")
include("Heuristic/Functions/Run_Heuristic.jl")
include("Optimization/Run_MIP.jl")

P = 4
T = 5
N = 10

#Set path for file locations
Path_stem = "Documents/Academic/Research/Julia/MTT/"

#Build new P x T scenario
@printf("Building a new scenario of %d targets for %d time steps.\n", P, T)
(Original_Partitions, Data, True_Positions) = build_scenario(P,T, Path_stem)


#Construct design matrices
X = ones(T, 2);
X[:,2] = 1:T;
M = eye(T)-X*inv(X'X)*X';

Performance = zeros(100,21)

@printf("Simulation number %d of %d x %d scenario with N = %d\n", 1, P,T,N)

#Run and time heuristic
@printf("Running heuristic with %d iterations...", N)
Start_time = time()
Heuristic_Partitions = run_heuristic(P, T, N, Data, M)
Heuristic_run_time = time() - Start_time
@printf("COMPLETE.\n")

#Run and time MIP optimization
@printf("Running MIP...")
(Optimized_Partitions) = run_MIP(P,T,N,1, Path_stem, Data, Heuristic_Partitions)
@printf("COMPLETE.\n\n")

#Calculate the true RSS
Heuristic_RSS = calc_trad_RSS(Heuristic_Partitions,P,M)
Optimal_RSS   = calc_trad_RSS(Optimized_Partitions,P,M)

#Calculate the effective RSS
Scenario_eff_RSS  = calc_eff_RSS(P, T, True_Positions, Original_Partitions, Original_Partitions)
Heuristic_eff_RSS = calc_eff_RSS(P, T, True_Positions, Heuristic_Partitions, Original_Partitions)
Optimized_eff_RSS = calc_eff_RSS(P, T, True_Positions, Optimized_Partitions, Original_Partitions)

#Calculate the traditional MAPE
(Heuristic_α_MAPE, Heuristic_β_MAPE) = calc_MAPE(P,T, Original_Partitions, Heuristic_Partitions, Original_Partitions)
(Optimized_α_MAPE, Optimized_β_MAPE) = calc_MAPE(P,T, Original_Partitions, Optimized_Partitions, Original_Partitions)

#Calculate the effective MAPE
(Scenario_eff_α_MAPE,  Scenario_eff_β_MAPE)  = calc_MAPE(P,T, True_Positions, Original_Partitions, Original_Partitions)
(Heuristic_eff_α_MAPE, Heuristic_eff_β_MAPE) = calc_MAPE(P,T, True_Positions, Heuristic_Partitions, Original_Partitions)
(Optimized_eff_α_MAPE, Optimized_eff_β_MAPE) = calc_MAPE(P,T, True_Positions, Optimized_Partitions, Original_Partitions)

#Extract MIP statistics
(MIP_times) = extract_times(P,T,N,1, Path_stem)

#Print information to console

println("RUN TIMES:")
println("\t\tMIP: prove\toptimal\t1% opt\t5% opt\t10% opt")
@printf("\t\t     %.4f\t%.4f\t%.4f\t%.4f\t%.4f\n",
        MIP_times[1],MIP_times[2],MIP_times[3],MIP_times[4],MIP_times[5])
println("\t  Heuristic: ", round(Heuristic_run_time,4))
println("\nPERFORMANCE SUMMARY:")
println("\t\t\tScenario \tHeuristic \tOptimized")
@printf("       Traditional RSS: N/a\t\t%.4f\t\t%.4f\n", Heuristic_RSS, Optimal_RSS)
@printf("\t Effective RSS:\t%.4f\t\t%.4f\t\t%.4f\n",
        Scenario_eff_RSS, Heuristic_eff_RSS, Optimized_eff_RSS)
@printf("\nTraditional Alpha MAPE: N/a\t\t%.4f\t\t%.4f\n", Heuristic_α_MAPE, Optimized_α_MAPE)
@printf("  Effective Alpha MAPE: %.4f\t\t%.4f\t\t%.4f\n",
        Scenario_eff_α_MAPE, Heuristic_eff_α_MAPE, Optimized_eff_α_MAPE)
@printf("\n Traditional Beta MAPE: N/a\t\t%.4f\t\t%.4f\n", Heuristic_β_MAPE, Optimized_β_MAPE)
@printf("   Effective Beta MAPE: %.4f\t\t%.4f\t\t%.4f\n\n",
        Scenario_eff_β_MAPE, Heuristic_eff_β_MAPE, Optimized_eff_β_MAPE)

#Collect all performance metric           #RUN TMES
Performance[1,1] = Heuristic_run_time     #Heuristic run time
Performance[1,2] = MIP_times[1]           #MIP time to prove optimality
Performance[1,3] = MIP_times[2]           #MIP time to find optimal solution
Performance[1,4] = MIP_times[3]           #MIP time to get within 10% of optimal solution
Performance[1,5] = MIP_times[4]           #MIP time to get within  5% of optimal solution
Performance[1,6] = MIP_times[5]           #MIP time to get within  1% of optimal solution

#Traditional RSS
Performance[1,7] = Heuristic_RSS
Performance[1,8] = Optimal_RSS

#Effective RSS
Performance[1,9]  = Scenario_eff_RSS
Performance[1,10] = Heuristic_eff_RSS
Performance[1,11] = Optimized_eff_RSS

#Traditional MAPE
Performance[1,12] = Heuristic_α_MAPE
Performance[1,13] = Optimized_α_MAPE
Performance[1,14] = Heuristic_β_MAPE
Performance[1,15] = Optimized_β_MAPE

#Traditional MAPE
Performance[1,16] = Scenario_eff_α_MAPE
Performance[1,17] = Heuristic_eff_α_MAPE
Performance[1,18] = Optimized_eff_α_MAPE
Performance[1,19] = Scenario_eff_β_MAPE
Performance[1,20] = Heuristic_eff_β_MAPE
Performance[1,21] = Optimized_eff_β_MAPE

#Write performance metric summary data to csv file
Write_path = string(Path_stem, "Test_Scenarios/Performance_Summaries/",
                    string(P), "x", string(T), "x", string(N), ".csv")
writecsv(Write_path, Performance)


writecsv(string(Path_stem,"/original.csv"), Original_Partitions)
writecsv(string(Path_stem,"/true.csv"), True_Positions)
writecsv(string(Path_stem,"/heuristic.csv"), Heuristic_Partitions)
writecsv(string(Path_stem,"/optimized.csv"), Optimized_Partitions)


Heuristic_index = solve_traj_assignment(P,T, Original_Partitions, Heuristic_Partitions)
Optimized_index = solve_traj_assignment(P,T, Original_Partitions, Optimized_Partitions)

println("Heuristic index: ", Heuristic_index)
println("Optimized index: ", Optimized_index)

#end script
