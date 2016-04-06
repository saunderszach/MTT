library(ggplot2)
library(dplyr)
library(tidyr)

setwd("~/Documents/Academic/Research/Git/Multi-Target-Tracking/Julia/Basic/Results")

Rho_Types = c("Average", "Min", "Alpha_Min", "Proximity")

Data = read.csv("Files/Objective.csv", header=TRUE, stringsAsFactors=TRUE)

Data$P             = factor(Data$P)
Data$T             = factor(Data$T)
Data$Scenario_num  = factor(Data$Scenario_num)
Data$Sigma         = factor(Data$Sigma)
Data$Sim_num       = factor(Data$Sim_num)
Data$N             = factor(Data$N)
Data$MIO_Time      = factor(Data$MIO_Time)
Data$Rho_Type      = factor(Data$Rho_Type, levels = Rho_Types)
Data$Solution_Type = factor(Data$Solution_Type, 
                            levels = c("Ideal","Random","Heuristic","Optimized"))

Data = Data %>% filter(MIO_Time == "1")

#####################################################
###                                               ###
###  Objective vs Sigma By Solution Type (POINTS)  ###
###                                               ###
#####################################################

Sigma_Data = Data %>% filter(Rho_Type=="Average", Solution_Type != "Ideal")
Sigma_Data$Solution_Type = factor(Sigma_Data$Solution_Type)

plot_1 = ggplot(data = Sigma_Data,
                aes(x=Sigma,
                    y=Objective,
                    color=Solution_Type)) + 
  geom_point() +
  facet_grid(P~T, labeller=label_both) +
  ggtitle(paste("Objective vs Sigma by Solution Type")) + 
  theme(axis.text=element_text(size=16),
        axis.title=element_text(size=18,face="bold"),
        plot.title=element_text(size = rel(2)),
        legend.text=element_text(size=14),
        legend.title=element_text(size=14),
        strip.text.x=element_text(size = 14),
        strip.text.y=element_text(size = 14)) +
  xlab("Sigma") +
  ylab("% of Correctly Labelled Detections")

Save_str = paste("Plots/Objective/vs_Sigma/Points_by_Solution_Type.png", sep="")
png(file=Save_str,width=1000, height=700)
print(plot_1)
dev.off()

######################################################
###                                                ###
###  Objective vs Sigma By Solution Type (AVERAGE)  ###
###                                                ###
######################################################

Sigma_Data2 = Sigma_Data %>% group_by(Solution_Type,P,T,Sigma) %>% summarize(mean.value=mean(Objective),max.value=max(Objective),min.value=min(Objective))

plot_2 = ggplot(data = Sigma_Data2,
                aes(x=Sigma,
                    y=mean.value,
                    color=Solution_Type)) +
  geom_line() +
  geom_ribbon(data=Sigma_Data2,
              aes(x=Sigma,
                  ymin=min.value,
                  ymax=max.value,
                  fill=Solution_Type),
              alpha=.1) +
  facet_grid(P~T, labeller=label_both) +
  ggtitle(paste("Objective vs Sigma by Solution Type")) +
  theme(axis.text=element_text(size=16),
        axis.title=element_text(size=18,face="bold"),
        plot.title=element_text(size = rel(2)),
        legend.text=element_text(size=14),
        legend.title=element_text(size=14),
        strip.text.x=element_text(size = 14),
        strip.text.y=element_text(size = 14)) +
  xlab("Sigma") +
  ylab("% of Correctly Labelled Detections")

Save_str = paste("Plots/Objective/vs_Sigma/Average_by_Solution_Type.png", sep="")
png(file=Save_str,width=1000, height=700)
print(plot_2)
dev.off()

#############################################################
###                                                       ###
###  Objective vs Sigma By N with Heuristic ONLY (POINTS)  ###
###                                                       ###
#############################################################

Heuristic_Data = Data%>%filter(Rho_Type=="Average", Solution_Type=="Heuristic")

plot_3 = ggplot(data = Heuristic_Data,
                aes(x=Sigma,
                    y=Objective,
                    color=N)) +
  geom_point() +
  facet_grid(P~T, labeller = label_both) + 
  ggtitle(paste("Objective vs Sigma by N (Heuristic Solutions Only)")) +
  theme(axis.text=element_text(size=16),
        axis.title=element_text(size=18,face="bold"),
        plot.title = element_text(size = rel(2)),
        legend.text=element_text(size=14),
        legend.title=element_text(size=14),
        strip.text.x = element_text(size = 14),
        strip.text.y = element_text(size = 14)) +
  xlab("Sigma") +
  ylab("% of Correctly Labelled Detections")

Save_str = paste("Plots/Objective/vs_Sigma/Points_Heuristic_only_by_N.png", sep="")
png(file=Save_str,width=1000, height=700)
print(plot_3)
dev.off()

##############################################################
###                                                        ###
###  Objective vs Sigma By N with Heuristic ONLY (AVERAGE)  ###
###                                                        ###
##############################################################

Heuristic_Data2 = Heuristic_Data %>% group_by(P,T,Sigma,N) %>% summarize(mean.value=mean(Objective),max.value=max(Objective),min.value=min(Objective))

plot_4 = ggplot(data = Heuristic_Data2,
                aes(x=Sigma,
                    y=mean.value,
                    color=N)) +
  geom_line() +
  geom_ribbon(data=Heuristic_Data2,
              aes(x=Sigma,
                  ymin=min.value,
                  ymax=max.value,
                  fill=N),
              alpha=.1) +
  facet_grid(P~T, labeller=label_both) +
  ggtitle(paste("Objective vs Sigma by N (Heuristic Solutions Only)")) +
  theme(axis.text=element_text(size=16),
        axis.title=element_text(size=18,face="bold"),
        plot.title=element_text(size = rel(2)),
        legend.text=element_text(size=14),
        legend.title=element_text(size=14),
        strip.text.x=element_text(size = 14),
        strip.text.y=element_text(size = 14)) +
  xlab("Sigma") +
  ylab("% of Correctly Labelled Detections")

Save_str = paste("Plots/Objective/vs_Sigma/Average_Heuristic_only_by_N.png", sep="")
png(file=Save_str,width=1000, height=700)
print(plot_4)
dev.off()

###################################################################
###                                                             ###
###  Objective vs Sigma By Scenario Type with MIO ONLY (POINTS)  ###
###                                                             ###
###################################################################

MIO_Data = Data%>%filter(Rho_Type=="Average", Solution_Type=="Optimized")

plot_5 = ggplot(data = MIO_Data,
                aes(x=Sigma,
                    y=Objective,
                    color=Scenario_Type)) +
  geom_point() +
  facet_grid(P~T, labeller = label_both) +
  ggtitle(paste("Objective vs Sigma by Scenario Type (MIO Solutions Only)")) + 
  theme(axis.text=element_text(size=16),
        axis.title=element_text(size=18,face="bold"),
        plot.title = element_text(size = rel(2)),
        legend.text=element_text(size=14),
        legend.title=element_text(size=14),
        strip.text.x = element_text(size = 14),
        strip.text.y = element_text(size = 14)) +
  xlab("Sigma") +
  ylab("% of Correctly Labelled Detections")

Save_str = paste("Plots/Objective/vs_Sigma/Points_MIO_only_by_Scenario_Type.png", sep="")
png(file=Save_str,width=1000, height=700)
print(plot_5)
dev.off()

####################################################################
###                                                              ###
###  Objective vs Sigma By Scenario Type with MIO ONLY (AVERAGE)  ###
###                                                              ###
####################################################################

MIO_Data2 = MIO_Data %>% group_by(P,T,Sigma,Scenario_Type) %>% summarize(mean.value=mean(Objective),max.value=max(Objective),min.value=min(Objective))

plot_6 = ggplot(data = MIO_Data2,
                aes(x=Sigma,
                    y=mean.value,
                    color=Scenario_Type)) +
  geom_line() +
  geom_ribbon(data=MIO_Data2,
              aes(x=Sigma,
                  ymin=min.value,
                  ymax=max.value,
                  fill=Scenario_Type),
              alpha=.1) +
  facet_grid(P~T, labeller=label_both) +
  ggtitle(paste("Objective vs Sigma by Scenario Type (MIO Solutions Only)")) +
  theme(axis.text=element_text(size=16),
        axis.title=element_text(size=18,face="bold"),
        plot.title=element_text(size = rel(2)),
        legend.text=element_text(size=14),
        legend.title=element_text(size=14),
        strip.text.x=element_text(size = 14),
        strip.text.y=element_text(size = 14)) +
  xlab("Sigma") +
  ylab("% of Correctly Labelled Detections")

Save_str = paste("Plots/Objective/vs_Sigma/Average_MIO_only_by_Scenario_Type.png", sep="")
png(file=Save_str,width=1000, height=700)
print(plot_6)
dev.off()

###################################################################
###                                                             ###
###  Objective vs Sigma By Scenario Type with MIO ONLY (POINTS)  ###
###                                                             ###
###################################################################

MIO_Data = Data%>%filter(Rho_Type=="Average", Solution_Type=="Optimized")

plot_7 = ggplot(data = MIO_Data,
                aes(x=Sigma,
                    y=Objective,
                    color=N)) +
  geom_point() +
  facet_grid(P~T, labeller = label_both) +
  ggtitle(paste("Objective vs Sigma by N (MIO Solutions Only)")) + 
  theme(axis.text=element_text(size=16),
        axis.title=element_text(size=18,face="bold"),
        plot.title = element_text(size = rel(2)),
        legend.text=element_text(size=14),
        legend.title=element_text(size=14),
        strip.text.x = element_text(size = 14),
        strip.text.y = element_text(size = 14)) +
  xlab("Sigma") +
  ylab("% of Correctly Labelled Detections")

Save_str = paste("Plots/Objective/vs_Sigma/Points_MIO_only_by_N.png", sep="")
png(file=Save_str,width=1000, height=700)
print(plot_7)
dev.off()

####################################################################
###                                                              ###
###  Objective vs Sigma By Scenario Type with MIO ONLY (AVERAGE)  ###
###                                                              ###
####################################################################

MIO_Data3 = MIO_Data %>% group_by(P,T,Sigma,N) %>% summarize(mean.value=mean(Objective),max.value=max(Objective),min.value=min(Objective))

plot_8 = ggplot(data = MIO_Data3,
                aes(x=Sigma,
                    y=mean.value,
                    color=N)) +
  geom_line() +
  geom_ribbon(data=MIO_Data3,
              aes(x=Sigma,
                  ymin=min.value,
                  ymax=max.value,
                  fill=N),
              alpha=.1) +
  facet_grid(P~T, labeller=label_both) +
  ggtitle(paste("Objective vs Sigma by N (MIO Solutions Only)")) +
  theme(axis.text=element_text(size=16),
        axis.title=element_text(size=18,face="bold"),
        plot.title=element_text(size = rel(2)),
        legend.text=element_text(size=14),
        legend.title=element_text(size=14),
        strip.text.x=element_text(size = 14),
        strip.text.y=element_text(size = 14)) +
  xlab("Sigma") +
  ylab("% of Correctly Labelled Detections")

Save_str = paste("Plots/Objective/vs_Sigma/Average_MIO_only_by_N.png", sep="")
png(file=Save_str,width=1000, height=700)
print(plot_8)
dev.off()

#####################################################
###                                               ###
###                                               ###
#####################################################

for (type in Rho_Types){
  
  #####################################################
  ###                                               ###
  ###  Objective vs Rho By Solution Type (POINTS)    ###
  ###                                               ###
  #####################################################
  
  Rho_Data = Data %>% filter(Rho_Type==type, Solution_Type != "Ideal")
  Rho_Data$Solution_Type = factor(Rho_Data$Solution_Type)
  
  plot_1 = ggplot(data = Rho_Data,
                  aes(x=Rho,
                      y=Objective,
                      color=Solution_Type)) + 
    geom_point() +
    facet_grid(P~T, labeller=label_both) +
    ggtitle(paste("Objective vs", type, "by Solution Type")) + 
    theme(axis.text=element_text(size=16),
          axis.title=element_text(size=18,face="bold"),
          plot.title=element_text(size = rel(2)),
          legend.text=element_text(size=14),
          legend.title=element_text(size=14),
          strip.text.x=element_text(size = 14),
          strip.text.y=element_text(size = 14)) +
    xlab(paste(type,"Rho")) +
    ylab("% of Correctly Labelled Detections")
  
  Save_str = paste("Plots/Objective/vs_",type,"/Points_by_Solution_Type.png", sep="")
  png(file=Save_str,width=1000, height=700)
  print(plot_1)
  dev.off()
  
  ######################################################
  ###                                                ###
  ###  Objective vs Rho By Solution Type (AVERAGE)    ###
  ###                                                ###
  ######################################################
  
  Rho_Data2 = Rho_Data %>% group_by(Solution_Type,P,T,Rho) %>% summarize(mean.value=mean(Objective),max.value=max(Objective),min.value=min(Objective))
  
  plot_2 = ggplot(data = Rho_Data2,
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
    ggtitle(paste("Objective vs", type, "by Solution Type")) +
    theme(axis.text=element_text(size=16),
          axis.title=element_text(size=18,face="bold"),
          plot.title=element_text(size = rel(2)),
          legend.text=element_text(size=14),
          legend.title=element_text(size=14),
          strip.text.x=element_text(size = 14),
          strip.text.y=element_text(size = 14)) +
    xlab(paste(type, "Rho")) +
    ylab("% of Correctly Labelled Detections")
  
  Save_str = paste("Plots/Objective/vs_", type, "/Average_by_Solution_Type.png", sep="")
  png(file=Save_str,width=1000, height=700)
  print(plot_2)
  dev.off()
  
  #############################################################
  ###                                                       ###
  ###  Objective vs Rho By N with Heuristic ONLY (POINTS)    ###
  ###                                                       ###
  #############################################################
  
  Heuristic_Data = Data%>%filter(Rho_Type==type, Solution_Type=="Heuristic")
  
  plot_3 = ggplot(data = Heuristic_Data,
                  aes(x=Rho,
                      y=Objective,
                      color=N)) +
    geom_point() +
    facet_grid(P~T, labeller = label_both) + 
    ggtitle(paste("Objective vs", type, "by N (Heuristic Solutions Only)")) +
    theme(axis.text=element_text(size=16),
          axis.title=element_text(size=18,face="bold"),
          plot.title = element_text(size = rel(2)),
          legend.text=element_text(size=14),
          legend.title=element_text(size=14),
          strip.text.x = element_text(size = 14),
          strip.text.y = element_text(size = 14)) +
    xlab(paste(type, "Rho")) +
    ylab("% of Correctly Labelled Detections")
  
  Save_str = paste("Plots/Objective/vs_", type, "/Points_Heuristic_only_by_N.png", sep="")
  png(file=Save_str,width=1000, height=700)
  print(plot_3)
  dev.off()
  
  ##############################################################
  ###                                                        ###
  ###  Objective vs Rho By N with Heuristic ONLY (AVERAGE)    ###
  ###                                                        ###
  ##############################################################
  
  Heuristic_Data2 = Heuristic_Data %>% group_by(P,T,Rho,N) %>% summarize(mean.value=mean(Objective),max.value=max(Objective),min.value=min(Objective))
  
  plot_4 = ggplot(data = Heuristic_Data2,
                  aes(x=Rho,
                      y=mean.value,
                      color=N)) +
    geom_line() +
    geom_ribbon(data=Heuristic_Data2,
                aes(x=Rho,
                    ymin=min.value,
                    ymax=max.value,
                    fill=N),
                alpha=.1) +
    facet_grid(P~T, labeller=label_both) +
    ggtitle(paste("Objective vs", type, "by N (Heuristic Solutions Only)")) +
    theme(axis.text=element_text(size=16),
          axis.title=element_text(size=18,face="bold"),
          plot.title=element_text(size = rel(2)),
          legend.text=element_text(size=14),
          legend.title=element_text(size=14),
          strip.text.x=element_text(size = 14),
          strip.text.y=element_text(size = 14)) +
    xlab(paste(type, "Rho")) +
    ylab("% of Correctly Labelled Detections")
  
  Save_str = paste("Plots/Objective/vs_", type, "/Average_Heuristic_only_by_N.png", sep="")
  png(file=Save_str,width=1000, height=700)
  print(plot_4)
  dev.off()
  
  ###################################################################
  ###                                                             ###
  ###  Objective vs Rho By Scenario Type with MIO ONLY (POINTS)    ###
  ###                                                             ###
  ###################################################################
  
  MIO_Data = Data%>%filter(Rho_Type==type, Solution_Type=="Optimized")
  
  plot_5 = ggplot(data = MIO_Data,
                  aes(x=Rho,
                      y=Objective,
                      color=Scenario_Type)) +
    geom_point() +
    facet_grid(P~T, labeller = label_both) +
    ggtitle(paste("Objective vs", type, "by Scenario Type (MIO Solutions Only)")) + 
    theme(axis.text=element_text(size=16),
          axis.title=element_text(size=18,face="bold"),
          plot.title = element_text(size = rel(2)),
          legend.text=element_text(size=14),
          legend.title=element_text(size=14),
          strip.text.x = element_text(size = 14),
          strip.text.y = element_text(size = 14)) +
    xlab(paste(type, "Rho")) +
    ylab("% of Correctly Labelled Detections")
  
  Save_str = paste("Plots/Objective/vs_", type, "/Points_MIO_only_by_Scenario_Type.png", sep="")
  png(file=Save_str,width=1000, height=700)
  print(plot_5)
  dev.off()
  
  ####################################################################
  ###                                                              ###
  ###  Objective vs Rho By Scenario Type with MIO ONLY (AVERAGE)    ###
  ###                                                              ###
  ####################################################################
  
  MIO_Data2 = MIO_Data %>% group_by(P,T,Rho,Scenario_Type) %>% summarize(mean.value=mean(Objective),max.value=max(Objective),min.value=min(Objective))
  
  plot_6 = ggplot(data = MIO_Data2,
                  aes(x=Rho,
                      y=mean.value,
                      color=Scenario_Type)) +
    geom_line() +
    geom_ribbon(data=MIO_Data2,
                aes(x=Rho,
                    ymin=min.value,
                    ymax=max.value,
                    fill=Scenario_Type),
                alpha=.1) +
    facet_grid(P~T, labeller=label_both) +
    ggtitle(paste("Objective vs", type, "by Scenario Type (MIO Solutions Only)")) +
    theme(axis.text=element_text(size=16),
          axis.title=element_text(size=18,face="bold"),
          plot.title=element_text(size = rel(2)),
          legend.text=element_text(size=14),
          legend.title=element_text(size=14),
          strip.text.x=element_text(size = 14),
          strip.text.y=element_text(size = 14)) +
    xlab(paste(type, "Rho")) +
    ylab("% of Correctly Labelled Detections")
  
  Save_str = paste("Plots/Objective/vs_", type, "/Average_MIO_only_by_Scenario_Type.png", sep="")
  png(file=Save_str,width=1000, height=700)
  print(plot_6)
  dev.off()
  
  ###################################################################
  ###                                                             ###
  ###  Objective vs Rho By Scenario Type with MIO ONLY (POINTS)    ###
  ###                                                             ###
  ###################################################################
  
  MIO_Data = Data%>%filter(Rho_Type==type, Solution_Type=="Optimized")
  
  plot_7 = ggplot(data = MIO_Data,
                  aes(x=Rho,
                      y=Objective,
                      color=N)) +
    geom_point() +
    facet_grid(P~T, labeller = label_both) +
    ggtitle(paste("Objective vs", type, "by N (MIO Solutions Only)")) + 
    theme(axis.text=element_text(size=16),
          axis.title=element_text(size=18,face="bold"),
          plot.title = element_text(size = rel(2)),
          legend.text=element_text(size=14),
          legend.title=element_text(size=14),
          strip.text.x = element_text(size = 14),
          strip.text.y = element_text(size = 14)) +
    xlab(paste(type, "Rho")) +
    ylab("% of Correctly Labelled Detections")
  
  Save_str = paste("Plots/Objective/vs_", type, "/Points_MIO_only_by_N.png", sep="")
  png(file=Save_str,width=1000, height=700)
  print(plot_7)
  dev.off()
  
  ####################################################################
  ###                                                              ###
  ###  Objective vs Sigma By Scenario Type with MIO ONLY (AVERAGE)  ###
  ###                                                              ###
  ####################################################################
  
  MIO_Data3 = MIO_Data %>% group_by(P,T,Rho,N) %>% summarize(mean.value=mean(Objective),max.value=max(Objective),min.value=min(Objective))
  
  plot_8 = ggplot(data = MIO_Data3,
                  aes(x=Rho,
                      y=mean.value,
                      color=N)) +
    geom_line() +
    geom_ribbon(data=MIO_Data3,
                aes(x=Rho,
                    ymin=min.value,
                    ymax=max.value,
                    fill=N),
                alpha=.1) +
    facet_grid(P~T, labeller=label_both) +
    ggtitle(paste("Objective vs", type, "by N (MIO Solutions Only)")) +
    theme(axis.text=element_text(size=16),
          axis.title=element_text(size=18,face="bold"),
          plot.title=element_text(size = rel(2)),
          legend.text=element_text(size=14),
          legend.title=element_text(size=14),
          strip.text.x=element_text(size = 14),
          strip.text.y=element_text(size = 14)) +
    xlab(paste(type, "Rho")) +
    ylab("% of Correctly Labelled Detections")
  
  Save_str = paste("Plots/Objective/vs_", type, "/Average_MIO_only_by_N.png", sep="")
  png(file=Save_str,width=1000, height=700)
  print(plot_8)
  dev.off()
}