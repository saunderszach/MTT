using JuMP, Gurobi

include("Functions/All_Misc_Functions.jl")
include("Data/Build_Scenario.jl")
include("Data/Generate_Data.jl")
include("Heuristic/Functions/Heuristic_Swap.jl")
include("Heuristic/Functions/Run_Heuristic.jl")
include("Optimization/Run_MIP_abs.jl")
include("Optimization/Run_MIP_quad.jl")
include("Optimization/Run_MIP_BigM10.jl")

#Define scenario parameters
P_range = [4]                        #Range of parameter values to test for P
T_range = [4]                        #Range of parameter values to test for T
N_range = [100]                      #Range of parameter values to test for N

#Set path for file locations
Path_stem = "Documents/Academic/Research/Julia/MTT/"

####################
P = 4;
T = 4;
#for P in P_range
#  for T in T_range

    for N in N_range
      Write_path = string(Path_stem, "Test_Scenarios/Performance_Summaries/",
                            string(P), "x", string(T), "/",
                            string(P), "x", string(T), "x", string(N), ".csv")
      fp = open(Write_path,"w")
      println(fp, "Heuristic_run_time,Time_to_prove,Time_to_opt,Time_to_one_percent,",
                  "Time_to_five_percent,Time_to_ten_percent,Heuristic_RSS,Optimal_RSS,",
                  "Scenario_eff_RSS,Heuristic_eff_RSS,Optimized_eff_RSS,Heuristic_alpha_MAPE,",
                  "Optimized_alpha_MAPE,Heuristic_beta_MAPE,Optimized_beta_MAPE,Scenario_eff_alpha_MAPE,",
                  "Heuristic_eff_alpha_MAPE,Optimized_eff_alpha_MAPE,Scenario_eff_beta_MAPE,",
                  "Heuristic_eff_beta_MAPE,Optimized_eff_beta_MAPE")
      close(fp)

    end
j = 2
    #
      #Build new P x T scenario
println("**************************************************************************")
@printf("Simulation number %d of 100\n", j)
@printf("Building a new scenario of %d targets for %d time steps.\n\n", P, T)
(Original_Partitions, Data, True_Positions, Big_M) = build_scenario(P,T, Path_stem)

#Construct design matrices
X      = ones(T, 2);
X[:,2] = 1:T;
M      = eye(T)-X*inv(X'X)*X';

N = 10
#for N in N_range

#Run and time heuristic
@printf("Running heuristic with %d iterations...", N)
Start_time = time()
Heuristic_Partitions = run_heuristic(P, T, N, Data, M)
Heuristic_run_time = time() - Start_time
@printf("COMPLETE.\n")

#Run and time Quad MIP with M=10
@printf("Running MIP with big M=10 (quadratic objective)...")
println(j)
(Optimized_Partitions) = run_MIP_BigM10(P,T,N,j,Big_M, Path_stem, Data, Heuristic_Partitions)
@printf("COMPLETE.\n\n")

#Extract Abs_MIP statistics
(M10_MIP_times) = extract_times(P,T,N,j, Path_stem)

#Run and time Abs MIP optimization
@printf("Running MIP with absolute value objective...")
(Optimized_Partitions) = run_MIP_abs(P,T,N,j,Big_M, Path_stem, Data, Heuristic_Partitions)
@printf("COMPLETE.\n\n")

#Extract Abs_MIP statistics
(Abs_MIP_times) = extract_times(P,T,N,j, Path_stem)

#Run and time Quad MIP optimization
@printf("Running MIP with quadratic objective...")
(Optimized_Partitions) = run_MIP_quad(P,T,N,j,Big_M, Path_stem, Data, Heuristic_Partitions)
@printf("COMPLETE.\n\n")

#Extract Quad MIP statistics
(Quad_MIP_times) = extract_times(P,T,N,j, Path_stem)

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

#Print information to console
println("RUN TIMES:")
        println("\t\tM10 MIP: prove\toptimal\t1% opt\t5% opt\t10% opt")
        @printf("\t\t\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\n",
                M10_MIP_times[1],M10_MIP_times[2],M10_MIP_times[3],M10_MIP_times[4],M10_MIP_times[5])
        println("\t\tAbs MIP: prove\toptimal\t1% opt\t5% opt\t10% opt")
        @printf("\t\t\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\n",
                Abs_MIP_times[1],Abs_MIP_times[2],Abs_MIP_times[3],Abs_MIP_times[4],Abs_MIP_times[5])
        println("\t\tQuad MIP: prove\toptimal\t1% opt\t5% opt\t10% opt")
        @printf("\t\t\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\n",
                Quad_MIP_times[1],Quad_MIP_times[2],Quad_MIP_times[3],Quad_MIP_times[4],Quad_MIP_times[5])
        println("\t  Heuristic: ", round(Heuristic_run_time,4))

        Write_path = string(Path_stem, "Test_Scenarios/Performance_Summaries/",
                            string(P), "x", string(T), "/",
                            string(P), "x", string(T), "x", string(N), ".csv")
        fp = open(Write_path,"a")
        println(fp, Heuristic_run_time,   ",",
                    M10_MIP_times[1],     ",",
                    M10_MIP_times[2],     ",",
                    M10_MIP_times[3],     ",",
                    M10_MIP_times[4],     ",",
                    M10_MIP_times[5],     ",",
                    Abs_MIP_times[1],     ",",
                    Abs_MIP_times[2],     ",",
                    Abs_MIP_times[3],     ",",
                    Abs_MIP_times[4],     ",",
                    Abs_MIP_times[5],     ",",
                    Quad_MIP_times[1],     ",",
                    Quad_MIP_times[2],     ",",
                    Quad_MIP_times[3],     ",",
                    Quad_MIP_times[4],     ",",
                    Quad_MIP_times[5])


        close(fp)
      #end
    #end
  #end
#end

#end script
