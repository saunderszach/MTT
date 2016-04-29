library(ggplot2)
library(dplyr)
library(tidyr)
library(RColorBrewer)

setwd('~/Desktop/Results/Robust/')

P_range = c(4,6,8,10)
T_range = c(4,6,8,10)
Num_sceanarios = 2
Sigma_range = c(0.1,0.5,1.0,2.0)
Gamma_range = c(0.8,0.85,0.9,0.95)
Lambda_range = c(0.1,0.5,1.0,2.0)

Summary = data.frame(P                  = integer(),
                     T                  = integer(),
                     Scenario_num       = integer(),
                     Sigma              = double(),
                     Gamma              = double(),
                     Lambda             = double(),
                     Sim_num            = integer(),
                     Theta              = double(),
                     Phi                = double(),
                     Test_P             = integer(),
                     MIO_Time           = integer(),
                     Rho                = double(),
                     Accuracy           = double(),
                     Delta              = double(),
                     Objective          = double(),
                     Solution_Type      = factor(),
                     Scenario_Type      = factor())
count = 1
for (P in P_range){
  for (T in T_range){
    for (Scenario_num in 1:Num_sceanarios){
      for (Sigma in Sigma_range){
        for (Gamma in Gamma_range){
          for (Lambda in Lambda_range){
            
            Sigma  = format(Sigma,  nsmall=1)
            Gamma  = format(Gamma,  nsmall=1)
            Lambda = format(Lambda, nsmall=1)
            
            read_path=paste("Results_Summaries/",
                            toString(P), "_", 
                            toString(T), "_", 
                            toString(Scenario_num), "_",
                            toString(Sigma), "_",
                            toString(Gamma), "_", 
                            toString(Lambda), ".csv", sep="")
            
            Raw_data = read.csv(read_path, header = TRUE)
            
            Summary = rbind(Summary, Raw_data)
            print(count)
            count = count + 1
          }
        }
      }
    }
  }
}

setwd("~/Desktop/Results/Robust/Files")
write.csv(file="Summary.csv", Summary, row.names = FALSE)

########################################################################