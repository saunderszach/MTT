library(ggplot2)
library(dplyr)
library(tidyr)

setwd("~/Documents/Academic/Research/Git/Multi-Target-Tracking/Julia/Basic/Results")

Rho_Types = c("Average", "Alpha_Min", "Min", "Proximity")

Raw_Data = read.csv("Files/Accuracy.csv", header=TRUE, stringsAsFactors=TRUE)

Raw_Data$P             = factor(Raw_Data$P)
Raw_Data$Scenario_num  = factor(Raw_Data$Scenario_num)
Raw_Data$Sigma         = factor(Raw_Data$Sigma)
Raw_Data$Sim_num       = factor(Raw_Data$Sim_num)
Raw_Data$N             = factor(Raw_Data$N)
Raw_Data$MIO_Time      = factor(Raw_Data$MIO_Time)
Raw_Data$Rho_Type      = factor(Raw_Data$Rho_Type, levels = Rho_Types)
Raw_Data$Solution_Type = factor(Raw_Data$Solution_Type, 
                            levels = c("Ideal","Random","Heuristic","Optimized"))

DataOpt1 = Raw_Data %>% filter(Solution_Type=="Optimized",
                               MIO_Time==1) %>% mutate(Solution_Type="Optimized t=1")
DataOpt2 = Raw_Data %>% filter(Solution_Type=="Optimized",
                               MIO_Time==T) %>% mutate(Solution_Type="Optimized t=T")
DataOpt3 = Raw_Data %>% filter(Solution_Type=="Optimized",
                               MIO_Time==2*T) %>% mutate(Solution_Type="Optimized t=2T")
DataOpt4 = Raw_Data %>% filter(Solution_Type=="Optimized",
                               MIO_Time==3*T) %>% mutate(Solution_Type="Optimized t=3T")

Data_subset = Raw_Data %>% filter(Solution_Type!="Optimized")

Data = rbind(Data_subset,DataOpt1,DataOpt2,DataOpt3,DataOpt4)

Data$T = factor(Data$T)
Data$Solution_Type = factor(Data$Solution_Type)

############################################
###                                      ###
###  Accuracy vs Sigma By Solution Type  ###
###                                      ###
############################################

Sigma_Data = Data %>% filter(Solution_Type != "Ideal", N == "10000") %>% group_by(P,T,Sigma,Solution_Type) %>% summarize(mean.value=mean(Accuracy),max.value=max(Accuracy),min.value=min(Accuracy))

Sigma_Data$Solution_Type = factor(Sigma_Data$Solution_Type)

plot_1 = ggplot(data = Sigma_Data,
                aes(x=Sigma,
                    y=mean.value,
                    color=Solution_Type)) +
  geom_jitter() +
  facet_grid(P~T, labeller=label_both) +
  ggtitle(paste("Accuracy vs Sigma by Solution Type")) +
  theme(axis.text=element_text(size=16),
        axis.title=element_text(size=18,face="bold"),
        plot.title=element_text(size = rel(2)),
        legend.text=element_text(size=14),
        legend.title=element_text(size=14),
        strip.text.x=element_text(size = 14),
        strip.text.y=element_text(size = 14)) +
  xlab("Sigma") +
  ylab("% of Correctly Labelled Detections")

Save_str = paste("Plots/Accuracy/vs_Sigma/Solution_Type.png", sep="")
png(file=Save_str,width=1000, height=700)
print(plot_1)
dev.off()

##########################################
###                                    ###
###  Heuristic Accuracy vs Sigma By N  ###
###                                    ###
##########################################
Heuristic_Data = Data%>%filter(Solution_Type=="Heuristic") %>% group_by(P,T,Sigma,N) %>% summarize(mean.value=mean(Accuracy),max.value=max(Accuracy),min.value=min(Accuracy))

plot_2 = ggplot(data = Heuristic_Data,
                aes(x=Sigma,
                    y=mean.value,
                    color=N)) +
  geom_jitter() +
  facet_grid(P~T, labeller=label_both) +
  ggtitle(paste("Heuristic Accuracy vs Sigma by N")) +
  theme(axis.text=element_text(size=16),
        axis.title=element_text(size=18,face="bold"),
        plot.title=element_text(size = rel(2)),
        legend.text=element_text(size=14),
        legend.title=element_text(size=14),
        strip.text.x=element_text(size = 14),
        strip.text.y=element_text(size = 14)) +
  xlab("Sigma") +
  ylab("% of Correctly Labelled Detections")

Save_str = paste("Plots/Accuracy/vs_Sigma/Heuristic_by_N.png", sep="")
png(file=Save_str,width=1000, height=700)
print(plot_2)
dev.off()

################################################
###                                          ###
###  MIO Accuracy vs Sigma By Scenario Type  ###
###                                          ###
################################################

MIO_Data = Data %>% filter(Solution_Type=="Optimized t=3T", N=="10000") %>% group_by(P,T,Sigma,Scenario_Type) %>% summarize(mean.value=mean(Accuracy),max.value=max(Accuracy),min.value=min(Accuracy))

plot_3 = ggplot(data = MIO_Data,
                aes(x=Sigma,
                    y=mean.value,
                    color=Scenario_Type)) +
  geom_jitter() +
  facet_grid(P~T, labeller=label_both) +
  ggtitle(paste("MIO Accuracy vs Sigma by Scenario Type")) +
  theme(axis.text=element_text(size=16),
        axis.title=element_text(size=18,face="bold"),
        plot.title=element_text(size = rel(2)),
        legend.text=element_text(size=14),
        legend.title=element_text(size=14),
        strip.text.x=element_text(size = 14),
        strip.text.y=element_text(size = 14)) +
  xlab("Sigma") +
  ylab("% of Correctly Labelled Detections")

Save_str = paste("Plots/Accuracy/vs_Sigma/MIO_by_Scenario_Type.png", sep="")
png(file=Save_str,width=1000, height=700)
print(plot_3)
dev.off()

################################################
###                                          ###
###  MIO Accuracy vs Sigma By Scenario Type  ###
###                                          ###
################################################

MIO_Data2 = Data %>% filter(Solution_Type=="Optimized t=3T") %>% group_by(P,T,Sigma,N) %>% summarize(mean.value=mean(Accuracy),max.value=max(Accuracy),min.value=min(Accuracy))

plot_4 = ggplot(data = MIO_Data2,
                aes(x=Sigma,
                    y=mean.value,
                    color=N)) +
  geom_jitter() +
  facet_grid(P~T, labeller=label_both) +
  ggtitle(paste("MIO Accuracy vs Sigma by N")) +
  theme(axis.text=element_text(size=16),
        axis.title=element_text(size=18,face="bold"),
        plot.title=element_text(size = rel(2)),
        legend.text=element_text(size=14),
        legend.title=element_text(size=14),
        strip.text.x=element_text(size = 14),
        strip.text.y=element_text(size = 14)) +
  xlab("Sigma") +
  ylab("% of Correctly Labelled Detections")

Save_str = paste("Plots/Accuracy/vs_Sigma/MIO_only_by_N.png", sep="")
png(file=Save_str,width=1000, height=700)
print(plot_4)
dev.off()


for (type in Rho_Types){
  
  Rho_Data = Data %>% filter(Rho_Type==type, Solution_Type != "Ideal")
  Rho_Data$Solution_Type = factor(Rho_Data$Solution_Type)
  
  ##########################################
  ###                                    ###
  ###  Accuracy vs Rho By Solution Type  ###
  ###                                    ###
  ##########################################
  
   Rho_Data2 = Rho_Data %>% filter(N=="10000") %>% group_by(P,T,Rho,Solution_Type) %>% summarize(mean.value=mean(Accuracy),max.value=max(Accuracy),min.value=min(Accuracy))
  
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
    ggtitle(paste("Accuracy vs", type, "by Solution Type")) +
    theme(axis.text=element_text(size=16),
          axis.title=element_text(size=18,face="bold"),
          plot.title=element_text(size = rel(2)),
          legend.text=element_text(size=14),
          legend.title=element_text(size=14),
          strip.text.x=element_text(size = 14),
          strip.text.y=element_text(size = 14)) +
    xlab(paste(type, "Rho")) +
    ylab("% of Correctly Labelled Detections")
  
  Save_str = paste("Plots/Accuracy/vs_", type, "/Solution_Type.png", sep="")
  png(file=Save_str,width=1000, height=700)
  print(plot_1)
  dev.off()
  
  ########################################
  ###                                  ###
  ###  Heuristic Accuracy vs Rho By N  ###
  ###                                  ###
  ########################################
  
  Heuristic_Data = Rho_Data%>%filter(Solution_Type=="Heuristic") %>% group_by(P,T,Rho,N) %>% summarize(mean.value=mean(Accuracy),max.value=max(Accuracy),min.value=min(Accuracy))
  
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
    ggtitle(paste("Heuristic Accuracy vs", type, "by N")) +
    theme(axis.text=element_text(size=16),
          axis.title=element_text(size=18,face="bold"),
          plot.title=element_text(size = rel(2)),
          legend.text=element_text(size=14),
          legend.title=element_text(size=14),
          strip.text.x=element_text(size = 14),
          strip.text.y=element_text(size = 14)) +
    xlab(paste(type, "Rho")) +
    ylab("% of Correctly Labelled Detections")
  
  Save_str = paste("Plots/Accuracy/vs_", type, "/Heuristic_by_N.png", sep="")
  png(file=Save_str,width=1000, height=700)
  print(plot_2)
  dev.off()
  
  ##############################################
  ###                                        ###
  ###  MIO Accuracy vs Rho By Scenario Type  ###
  ###                                        ###
  ##############################################
  
  MIO_Data = Rho_Data %>% filter(Solution_Type=="Optimized t=3T", N=="10000") %>% group_by(P,T,Rho,Scenario_Type) %>% summarize(mean.value=mean(Accuracy),max.value=max(Accuracy),min.value=min(Accuracy))
  
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
    ggtitle(paste("MIO Accuracy vs", type, "by Scenario Type")) +
    theme(axis.text=element_text(size=16),
          axis.title=element_text(size=18,face="bold"),
          plot.title=element_text(size = rel(2)),
          legend.text=element_text(size=14),
          legend.title=element_text(size=14),
          strip.text.x=element_text(size = 14),
          strip.text.y=element_text(size = 14)) +
    xlab(paste(type, "Rho")) +
    ylab("% of Correctly Labelled Detections")
  
  Save_str = paste("Plots/Accuracy/vs_", type, "/MIO_by_Scenario_Type.png", sep="")
  png(file=Save_str,width=1000, height=700)
  print(plot_3)
  dev.off()
  
  ##################################
  ###                            ###
  ###  MIO Accuracy vs Rho By N  ###
  ###                            ###
  ##################################
  
  MIO_Data2 = Rho_Data %>% filter(Solution_Type=="Optimized t=3T", N=="10000")  %>% group_by(P,T,Rho,N) %>% summarize(mean.value=mean(Accuracy),max.value=max(Accuracy),min.value=min(Accuracy))
  
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
    ggtitle(paste("MIO Accuracy vs", type, "by N")) +
    theme(axis.text=element_text(size=16),
          axis.title=element_text(size=18,face="bold"),
          plot.title=element_text(size = rel(2)),
          legend.text=element_text(size=14),
          legend.title=element_text(size=14),
          strip.text.x=element_text(size = 14),
          strip.text.y=element_text(size = 14)) +
    xlab(paste(type, "Rho")) +
    ylab("% of Correctly Labelled Detections")
  
  Save_str = paste("Plots/Accuracy/vs_", type, "/MIO_by_N.png", sep="")
  png(file=Save_str,width=1000, height=700)
  print(plot_4)
  dev.off()
}
