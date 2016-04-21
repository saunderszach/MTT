library(ggplot2)
library(dplyr)
library(tidyr)
library(RColorBrewer)

setwd('~/Desktop/Results/Robust/')

Raw_Data = read.csv('Files/Summary.csv', 
                    header=TRUE, 
                    stringsAsFactors=TRUE)

Raw_Data$P             = factor(Raw_Data$P)
Raw_Data$Scenario_num  = factor(Raw_Data$Scenario_num)
Raw_Data$Test_P        = factor(Raw_Data$Test_P)
Raw_Data$Sim_num       = factor(Raw_Data$Sim_num)
Raw_Data$MIO_Time      = factor(Raw_Data$MIO_Time)
Raw_Data$Solution_Type = factor(Raw_Data$Solution_Type, 
                                levels = c('Ideal',
                                           'Random',
                                           'Heuristic',
                                           'Optimized'))

DataOpt1 = Raw_Data %>% filter(Solution_Type=='Optimized',
                               MIO_Time==1) %>% mutate(Solution_Type='MIO_1_sec')
DataOpt2 = Raw_Data %>% filter(Solution_Type=='Optimized',
                               MIO_Time==T) %>% mutate(Solution_Type='MIO_T_sec')
DataOpt3 = Raw_Data %>% filter(Solution_Type=='Optimized',
                               MIO_Time==2*T) %>% mutate(Solution_Type='MIO_2T_sec')
DataOpt4 = Raw_Data %>% filter(Solution_Type=='Optimized',
                               MIO_Time==3*T) %>% mutate(Solution_Type='MIO_3T_sec')

Data_subset = Raw_Data %>% filter(Solution_Type!='Optimized')

Data = rbind(Data_subset,DataOpt1,DataOpt2,DataOpt3,DataOpt4)

Data$T = factor(Data$T)
Data$Solution_Type = factor(Data$Solution_Type, 
                            levels = c('Random',
                                       'Heuristic',
                                       'MIO_1_sec',
                                       'MIO_T_sec',
                                       'MIO_2T_sec',
                                       'MIO_3T_sec',
                                       'Ideal'))

Temp = Data %>% group_by(P,T,Scenario_num,Sigma,Gamma,Lambda,Sim_num,Theta,Phi,Solution_Type) %>% filter(min_rank(Objective) <= 1) %>% ungroup()
