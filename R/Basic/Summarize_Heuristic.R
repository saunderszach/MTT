library(ggplot2)
library(dplyr)
library(tidyr)
library(xtable)

setwd("~/Desktop/Results/Basic/Simulation_Summaries")

P_range = c(4,6,8,10)
T_range = c(4,6,8,10)
Sigma_range = c(0.1,0.5,1.0,2.0,3.5,5.0)
Num_scenarios = 20
Num_sims = 10
N_range = c(100, 1000, 10000)
Time_limit = c(1)

num_rows=length(P_range)*length(T_range)*length(Sigma_range)*Num_scenarios*Num_sims*length(N_range)

Summary = data.frame(P                  = integer(num_rows),
                     T                  = integer(num_rows),
                     Scenario_num       = integer(num_rows),
                     Sigma              = double(num_rows),
                     Sim_num            = integer(num_rows),
                     N                  = integer(num_rows),
                     Heuristic_run_time = double(num_rows))

count = 0
for (P in P_range){
  for (T in T_range){
    for (Scenario_num in 1:Num_scenarios){
      for (Sim_num in 1:Num_sims){
        for (Sigma in Sigma_range){
          for (N in N_range){
              
            Sigma = format(Sigma, nsmall=1)
              
            Data=read.csv(paste(toString(P), "/", 
                                toString(T), "/", 
                                toString(Scenario_num), "_",
                                toString(Sigma), "_",
                                toString(Sim_num), "_",
                                toString(N), "_", 
                                toString(Time_limit), ".csv",
                                sep=""), header=TRUE)

            Temp=Data %>% select(P, T, Scenario_num, Sigma,
                                 Sim_num, N, Heuristic_run_time)
            
            Summary[count,] = Temp
              
            count = count + 1
          }
        }
      }
    }
  }
}

setwd("~/Desktop/Results/Basic/Files")
write.csv(file="Summary.csv", Summary, row.names = FALSE)

Summary = read.csv("Summary.csv")

Summary = Summary %>% filter(P!=0, T!=0, N==1000)
Summary$P = factor(Summary$P)
Summary$T = factor(Summary$T)
Summary$Scenario_num = factor(Summary$Scenario_num)
Summary$Sim_num = factor(Summary$Sim_num)
Summary$N = factor(Summary$N)

Table_data = Summary %>% group_by(P, T) %>% summarize(Min_time=min(Heuristic_run_time), Mean_time=mean(Heuristic_run_time), Max_time=max(Heuristic_run_time))

xtable(Table_data)


              