using JuMP, Gurobi

include("Functions/All_Misc_Functions.jl")
include("Data/Build_Scenario.jl")
include("Data/Generate_Data.jl")
include("Heuristic/Functions/Heuristic_Swap.jl")
include("Heuristic/Functions/Run_Heuristic.jl")
include("Optimization/Run_MIP.jl")

P = 4
T = 4
N = 10

Path_stem = "Documents/Academic/Research/Julia/MTT/"
dir_path = string(Path_stem,"Test_Scenarios/Performance_Summaries/",string(P),"x",string(T),"/")
mkdir(dir_path)

Write_path = string(Path_stem, "Test_Scenarios/Performance_Summaries/",
                    string(P), "x", string(T), "/",
                    string(P), "x", string(T), "x", string(N), ".csv")

fp = open(Write_path,"w")

println(fp, "Heuristic_Run_Time,Time_to_prove,Time_to_Optimal,Time_to_One_Percent,",
                  "Time_to_Five_Percent,Time_to_Ten_Percent")
close(fp)

s = 1

#Build new P x T scenario
println("**************************************************************************")
@printf("Simulation number %d of 100\n", s)
@printf("Building a new scenario of %d targets for %d time steps.\n\n", P, T)
(Original_Partitions, Data, True_Positions, Big_M) = build_scenario(P,T, Path_stem)

#Construct design matrices
X      = ones(T, 2);
X[:,2] = 1:T;
M      = eye(T)-X*inv(X'X)*X';

mkdir(string(Path_stem,"Test_Scenarios/MIP_Results/",string(P),"x",string(T)))

mkdir(string(Path_stem,"Test_Scenarios/MIP_Results/",string(P),"x",string(T),"/",
                    string(P),"x",string(T),"x",string(N))

        #Run and time heuristic
        @printf("Running heuristic with %d iterations...", N)
        Start_time = time()
        Heuristic_Partitions = run_heuristic(P, T, N, Data, M)
        Heuristic_Run_Time = time() - Start_time
        @printf("COMPLETE.\n\n")

        #Run and time MIP
        @printf("Running MIP (quadratic objective)...")
        (Optimized_Partitions) = run_MIP(P,T,N,s,Big_M, Path_stem, Data, Heuristic_Partitions)
        @printf("COMPLETE.\n\n")

        #Extract summary of MIP Times
        (MIP_Times) = extract_times(P,T,N,s, Path_stem, "")

        #Print information to console
        println("RUN TIMES:")

        println("\t\tMIP: \tprove\toptimal\t1% opt\t5% opt\t10% opt")
        @printf("\t\t\t\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\n",
                MIP_Times[1],MIP_Times[2],MIP_Times[3],MIP_Times[4],MIP_Times[5])

        println("___________________________________________________________________\n")

        Write_path = string(Path_stem, "Test_Scenarios/Performance_Summaries/",
                            string(P), "x", string(T), "/",
                            string(P), "x", string(T), "x", string(N), ".csv")

        fp = open(Write_path,"a")
        println(fp, Heuristic_Run_Time, ",",
                    MIP_Times[1],       ",",
                    MIP_Times[2],       ",",
                    MIP_Times[3],       ",",
                    MIP_Times[4],       ",",
                    MIP_Times[5])
        close(fp)
