library(dplyr)
library(tidyr)
library(inline)
library(xtable)

setwd("~/Desktop/Results/Robust/Files")

Raw_Data = read.csv("Heuristic_summary.csv",
                header=TRUE, 
                stringsAsFactors=TRUE)

Data = Raw_Data %>% select(P,T,Scenario_num,Sigma,Gamma,Lambda,Sim_num,Theta,Phi,Test_P,Heuristic_run_time)

Data$P = factor(Data$P)
Data$T = factor(Data$T)
Data$Scenario_num = factor(Data$Scenario_num)
Data$Sigma = factor(Data$Sigma)
Data$Gamma = factor(Data$Gamma)
Data$Lambda = factor(Data$Lambda)
Data$Sim_num = factor(Data$Sim_num)
Data$Test_P = factor(Data$Test_P)

Selected = c('2','4','6','8','10','12')

DataNew = Data[Data$Test_P %in% Selected,]

DataNew$Test_P = factor(DataNew$Test_P)

DataSubset = DataNew %>% group_by(Test_P, T) %>% summarize(Min_time=min(Heuristic_run_time), Mean_time=mean(Heuristic_run_time), Max_time=max(Heuristic_run_time)) %>% ungroup()

DataSubset

xtable(DataSubset)


