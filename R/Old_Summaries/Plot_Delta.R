library(ggplot2)
library(dplyr)
library(tidyr)

setwd("~/Desktop/Results/Basic/")

Rho_Types = c("Average", "Proximity")

Raw_Data = read.csv("Files/Delta.csv", header=TRUE, stringsAsFactors=TRUE)

Raw_Data$P             = factor(Raw_Data$P)
Raw_Data$Scenario_num  = factor(Raw_Data$Scenario_num)
Raw_Data$Sim_num       = factor(Raw_Data$Sim_num)
Raw_Data$N             = factor(Raw_Data$N)
Raw_Data$MIO_Time      = factor(Raw_Data$MIO_Time)
Raw_Data$Rho_Type      = factor(Raw_Data$Rho_Type, levels = Rho_Types)
Raw_Data$Solution_Type = factor(Raw_Data$Solution_Type, 
                                levels = c("Ideal","Random","Heuristic","Optimized"))

DataOpt1 = Raw_Data %>% filter(Solution_Type=="Optimized",
                               MIO_Time==1) %>% mutate(Solution_Type="MIO_1_sec")
DataOpt2 = Raw_Data %>% filter(Solution_Type=="Optimized",
                               MIO_Time==T) %>% mutate(Solution_Type="MIO_T_sec")
DataOpt3 = Raw_Data %>% filter(Solution_Type=="Optimized",
                               MIO_Time==2*T) %>% mutate(Solution_Type="MIO_2T_sec")
DataOpt4 = Raw_Data %>% filter(Solution_Type=="Optimized",
                               MIO_Time==3*T) %>% mutate(Solution_Type="MIO_3T_sec")

Data_subset = Raw_Data %>% filter(Solution_Type!="Optimized")

Data = rbind(Data_subset,DataOpt1,DataOpt2,DataOpt3,DataOpt4)

Data$T = factor(Data$T)
Data$Solution_Type = factor(Data$Solution_Type)

############################################
###                                      ###
###  Delta vs Sigma By Solution Type  ###
###                                      ###
############################################

Sigma_Data = Data %>% filter(Solution_Type!="MIO_3T_sec", N == "1000") %>% group_by(P,T,Sigma,Solution_Type) %>% summarize(mean.value=mean(Delta),max.value=max(Delta),min.value=min(Delta))

Sigma_Data$Solution_Type = factor(Sigma_Data$Solution_Type)

plot_1 = ggplot(data = Sigma_Data,
                aes(x=Sigma,
                    y=mean.value,
                    color=Solution_Type)) +
  geom_line() +
#   geom_ribbon(data=Sigma_Data,
#               aes(x=Sigma,
#                   ymin=min.value,
#                   ymax=max.value,
#                   fill=Solution_Type),
#               alpha=.1) +
  facet_grid(P~T, labeller=label_both) +
  ggtitle(paste("Mean Delta vs Sigma by Solution Type")) +
  theme(axis.text=element_text(size=16),
        axis.title=element_text(size=18,face="bold"),
        plot.title=element_text(size = rel(2)),
        legend.text=element_text(size=14),
        legend.title=element_text(size=14),
        strip.text.x=element_text(size = 14),
        strip.text.y=element_text(size = 14)) +
  xlab("Sigma") +
  ylab("Delta")

Save_str = paste("Plots/Delta/vs_Sigma/Solution_Type.png", sep="")
png(file=Save_str,width=1000, height=700)
print(plot_1)
dev.off()

##########################################
###                                    ###
###  Heuristic Delta vs Sigma By N  ###
###                                    ###
##########################################
Heuristic_Data = Data%>%filter(Solution_Type=="Heuristic") %>% group_by(P,T,Sigma,N) %>% summarize(mean.value=mean(Delta),max.value=max(Delta),min.value=min(Delta))

plot_2 = ggplot(data = Heuristic_Data,
                aes(x=Sigma,
                    y=mean.value,
                    color=N)) +
  geom_line() +
  geom_ribbon(data=Heuristic_Data,
              aes(x=Sigma,
                  ymin=min.value,
                  ymax=max.value,
                  fill=N),
              alpha=.1) +
  facet_grid(P~T, labeller=label_both) +
  ggtitle(paste("Mean Heuristic Delta vs Sigma by N")) +
  theme(axis.text=element_text(size=16),
        axis.title=element_text(size=18,face="bold"),
        plot.title=element_text(size = rel(2)),
        legend.text=element_text(size=14),
        legend.title=element_text(size=14),
        strip.text.x=element_text(size = 14),
        strip.text.y=element_text(size = 14)) +
  xlab("Sigma") +
  ylab("Delta")

Save_str = paste("Plots/Delta/vs_Sigma/Heuristic_by_N.png", sep="")
png(file=Save_str,width=1000, height=700)
print(plot_2)
dev.off()

################################################
###                                          ###
###  MIO Delta vs Sigma By Scenario Type  ###
###                                          ###
################################################

MIO_Data = Data %>% filter(Solution_Type=="MIO_3T_sec", N=="1000") %>% group_by(P,T,Sigma,Scenario_Type) %>% summarize(mean.value=mean(Delta),max.value=max(Delta),min.value=min(Delta))

plot_3 = ggplot(data = MIO_Data,
                aes(x=Sigma,
                    y=mean.value,
                    color=Scenario_Type)) +
  geom_line() +
  geom_ribbon(data=MIO_Data,
              aes(x=Sigma,
                  ymin=min.value,
                  ymax=max.value,
                  fill=Scenario_Type),
              alpha=.1) +
  facet_grid(P~T, labeller=label_both) +
  ggtitle(paste("Mean MIO Delta vs Sigma by Scenario Type")) +
  theme(axis.text=element_text(size=16),
        axis.title=element_text(size=18,face="bold"),
        plot.title=element_text(size = rel(2)),
        legend.text=element_text(size=14),
        legend.title=element_text(size=14),
        strip.text.x=element_text(size = 14),
        strip.text.y=element_text(size = 14)) +
  xlab("Sigma") +
  ylab("Delta")

Save_str = paste("Plots/Delta/vs_Sigma/MIO_by_Scenario_Type.png", sep="")
png(file=Save_str,width=1000, height=700)
print(plot_3)
dev.off()

################################################
###                                          ###
###  MIO Delta vs Sigma By N  ###
###                                          ###
################################################

MIO_Data2 = Data %>% filter(Solution_Type=="MIO_3T_sec") %>% group_by(P,T,Sigma,N) %>% summarize(mean.value=mean(Delta),max.value=max(Delta),min.value=min(Delta))

plot_4 = ggplot(data = MIO_Data2,
                aes(x=Sigma,
                    y=mean.value,
                    color=N)) +
  geom_line() +
  geom_ribbon(data=MIO_Data2,
              aes(x=Sigma,
                  ymin=min.value,
                  ymax=max.value,
                  fill=N),
              alpha=.1) +
  facet_grid(P~T, labeller=label_both) +
  ggtitle(paste("Mean MIO Delta vs Sigma by N")) +
  theme(axis.text=element_text(size=16),
        axis.title=element_text(size=18,face="bold"),
        plot.title=element_text(size = rel(2)),
        legend.text=element_text(size=14),
        legend.title=element_text(size=14),
        strip.text.x=element_text(size = 14),
        strip.text.y=element_text(size = 14)) +
  xlab("Sigma") +
  ylab("Delta")

Save_str = paste("Plots/Delta/vs_Sigma/MIO_by_N.png", sep="")
png(file=Save_str,width=1000, height=700)
print(plot_4)
dev.off()

for (type in Rho_Types){
  
  Rho_Data = Data %>% filter(Rho_Type==type, Solution_Type != "Ideal")
  Rho_Data$Solution_Type = factor(Rho_Data$Solution_Type)
  
  ##########################################
  ###                                    ###
  ###  Delta vs Rho By Solution Type  ###
  ###                                    ###
  ##########################################
  
  Rho_Data2 = Rho_Data %>% filter(Solution_Type!="MIO_3T_sec", N=="1000") %>% group_by(P,T,Rho,Solution_Type) %>% summarize(mean.value=mean(Delta),max.value=max(Delta),min.value=min(Delta))
  
  plot_1 = ggplot(data = Rho_Data2,
                  aes(x=Rho,
                      y=mean.value,
                      color=Solution_Type)) +
    geom_line() +
    geom_ribbon(data=Rho_Data2,
                aes(x=Rho,
                    ymin=min.value,
                    ymax=max.value,
                    fill=Solution_Type),
                alpha=.1) +
    facet_grid(P~T, labeller=label_both) +
    ggtitle(paste("Mean Delta vs", type, "Rho by Solution Type")) +
    theme(axis.text=element_text(size=16),
          axis.title=element_text(size=18,face="bold"),
          plot.title=element_text(size = rel(2)),
          legend.text=element_text(size=14),
          legend.title=element_text(size=14),
          strip.text.x=element_text(size = 14),
          strip.text.y=element_text(size = 14)) +
    xlab(paste(type, "Rho")) +
    ylab("Delta")
  
  Save_str = paste("Plots/Delta/vs_", type, "/Solution_Type.png", sep="")
  png(file=Save_str,width=1000, height=700)
  print(plot_1)
  dev.off()
  
  ########################################
  ###                                  ###
  ###  Heuristic Delta vs Rho By N  ###
  ###                                  ###
  ########################################
  
  Heuristic_Data = Rho_Data%>%filter(Solution_Type=="Heuristic") %>% group_by(P,T,Rho,N) %>% summarize(mean.value=mean(Delta),max.value=max(Delta),min.value=min(Delta))
  
  plot_2 = ggplot(data = Heuristic_Data,
                  aes(x=Rho,
                      y=mean.value,
                      color=N)) +
    geom_line() +
    geom_ribbon(data=Heuristic_Data,
                aes(x=Rho,
                    ymin=min.value,
                    ymax=max.value,
                    fill=N),
                alpha=.1) +
    facet_grid(P~T, labeller=label_both) +
    ggtitle(paste("Mean Heuristic Delta vs", type, "Rho by N")) +
    theme(axis.text=element_text(size=16),
          axis.title=element_text(size=18,face="bold"),
          plot.title=element_text(size = rel(2)),
          legend.text=element_text(size=14),
          legend.title=element_text(size=14),
          strip.text.x=element_text(size = 14),
          strip.text.y=element_text(size = 14)) +
    xlab(paste(type, "Rho")) +
    ylab("Delta")
  
  Save_str = paste("Plots/Delta/vs_", type, "/Heuristic_by_N.png", sep="")
  png(file=Save_str,width=1000, height=700)
  print(plot_2)
  dev.off()
  
  ##############################################
  ###                                        ###
  ###  MIO Delta vs Rho By Scenario Type  ###
  ###                                        ###
  ##############################################
  
  MIO_Data = Rho_Data %>% filter(Solution_Type=="MIO_3T_sec", N=="1000") %>% group_by(P,T,Rho,Scenario_Type) %>% summarize(mean.value=mean(Delta),max.value=max(Delta),min.value=min(Delta))
  
  plot_3 = ggplot(data = MIO_Data,
                  aes(x=Rho,
                      y=mean.value,
                      color=Scenario_Type)) +
    geom_line() +
    geom_ribbon(data=MIO_Data,
                aes(x=Rho,
                    ymin=min.value,
                    ymax=max.value,
                    fill=Scenario_Type),
                alpha=.1) +
    facet_grid(P~T, labeller=label_both) +
    ggtitle(paste("Mean MIO Delta vs", type, "Rho by Scenario Type")) +
    theme(axis.text=element_text(size=16),
          axis.title=element_text(size=18,face="bold"),
          plot.title=element_text(size = rel(2)),
          legend.text=element_text(size=14),
          legend.title=element_text(size=14),
          strip.text.x=element_text(size = 14),
          strip.text.y=element_text(size = 14)) +
    xlab(paste(type, "Rho")) +
    ylab("Delta")
  
  Save_str = paste("Plots/Delta/vs_", type, "/MIO_by_Scenario_Type.png", sep="")
  png(file=Save_str,width=1000, height=700)
  print(plot_3)
  dev.off()
  
  ##################################
  ###                            ###
  ###  MIO Delta vs Rho By N  ###
  ###                            ###
  ##################################
  
  MIO_Data2 = Rho_Data %>% filter(Solution_Type=="MIO_3T_sec", N=="1000")  %>% group_by(P,T,Rho,N) %>% summarize(mean.value=mean(Delta),max.value=max(Delta),min.value=min(Delta))
  
  plot_4 = ggplot(data = MIO_Data2,
                  aes(x=Rho,
                      y=mean.value,
                      color=N)) +
    geom_line() +
    geom_ribbon(data=MIO_Data2,
                aes(x=Rho,
                    ymin=min.value,
                    ymax=max.value,
                    fill=N),
                alpha=.1) +
    facet_grid(P~T, labeller=label_both) +
    ggtitle(paste("Mean MIO Delta vs", type, "by N")) +
    theme(axis.text=element_text(size=16),
          axis.title=element_text(size=18,face="bold"),
          plot.title=element_text(size = rel(2)),
          legend.text=element_text(size=14),
          legend.title=element_text(size=14),
          strip.text.x=element_text(size = 14),
          strip.text.y=element_text(size = 14)) +
    xlab(paste(type, "Rho")) +
    ylab("Delta")
  
  Save_str = paste("Plots/Delta/vs_", type, "/MIO_by_N.png", sep="")
  png(file=Save_str,width=1000, height=700)
  print(plot_4)
  dev.off()
}