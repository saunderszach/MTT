library(ggplot2)
library(dplyr)
library(tidyr)
library(RColorBrewer)

setwd('~/Desktop/Results/Basic/')

Raw_Data = read.csv('Files/Accuracy.csv', 
                    header=TRUE, 
                    stringsAsFactors=TRUE)

Raw_Data$P             = factor(Raw_Data$P)
Raw_Data$Scenario_num  = factor(Raw_Data$Scenario_num)
Raw_Data$Sim_num       = factor(Raw_Data$Sim_num)
Raw_Data$N             = factor(Raw_Data$N)
Raw_Data$MIO_Time      = factor(Raw_Data$MIO_Time)
Raw_Data$Rho_Type      = factor(Raw_Data$Rho_Type)
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
group.name = c('Random',
               'Heuristic',
               'MIO_1_sec',
               'MIO_T_sec',
               'MIO_2T_sec',
               'Ideal')

group.colors = brewer.pal(6, 'Set2')


############################################
###                                      ###
###  Accuracy vs Sigma By Solution Type  ###
###                                      ###
############################################

Sigma_Data = Data %>% filter(Solution_Type!='MIO_3T_sec', Solution_Type != 'Ideal', N == '1000') %>% group_by(P,T,Sigma,Solution_Type) %>% summarize(mean.value=mean(Accuracy),max.value=max(Accuracy),min.value=min(Accuracy))

Sigma_Data$Solution_Type = factor(Sigma_Data$Solution_Type)

Labels = c('Random',
           'Heuristic',
           'MIO (1sec)',
           'MIO (Tsec)',
           'MIO (2T sec)')

plot_1 = ggplot(data = Sigma_Data,
                aes(x=Sigma,
                    y=mean.value,
                    color=Solution_Type)) +
  geom_line(size = 0.9) +
  facet_grid(P~T, labeller=label_both) +
  ggtitle(paste('Mean Accuracy vs Sigma by Solution Type')) +
  theme(axis.text=element_text(size=16),
        axis.title=element_text(size=18,face='bold'),
        plot.title=element_text(size = rel(2)),
        legend.text=element_text(size=14),
        legend.title=element_text(size=14),
        strip.text.x=element_text(size = 14),
        strip.text.y=element_text(size = 14)) +
  xlab('Sigma') +
  ylab('% of Correctly Labelled Detections') +
  scale_color_manual(name = '',
                     values=group.colors[1:5], 
                     labels=Labels) + 
  theme(legend.position = "bottom") 

Save_str = 'Plots/Accuracy/vs_Sigma_Solution_Type.png'
png(file=Save_str,width=1000, height=700)
print(plot_1)
dev.off()

##########################################
###                                    ###
###  Heuristic Accuracy vs Sigma By N  ###
###                                    ###
##########################################
Heuristic_Data = Data%>%filter(Solution_Type=='Heuristic') %>% group_by(P,T,Sigma,N) %>% summarize(mean.value=mean(Accuracy),max.value=max(Accuracy),min.value=min(Accuracy))

plot_2 = ggplot(data = Heuristic_Data,
                aes(x=Sigma,
                    y=mean.value,
                    color=N)) +
  geom_line(size = 0.9) +
  facet_grid(P~T, labeller=label_both) +
  ggtitle(paste('Mean Heuristic Accuracy vs Sigma by Number of Starting Points (N)')) +
  theme(axis.text=element_text(size=16),
        axis.title=element_text(size=18,face='bold'),
        plot.title=element_text(size = rel(2)),
        legend.text=element_text(size=14),
        legend.title=element_text(size=14),
        strip.text.x=element_text(size = 14),
        strip.text.y=element_text(size = 14)) +
  xlab('Sigma') +
  ylab('% of Correctly Labelled Detections') + 
  theme(legend.position = "bottom")  

Save_str = 'Plots/Accuracy/vs_Sigma_Heuristic_by_N.png'
png(file=Save_str,width=1000, height=700)
print(plot_2)
dev.off()

################################################
###                                          ###
###  MIO Accuracy vs Sigma By Scenario Type  ###
###                                          ###
################################################

MIO_Data = Data %>% filter(Solution_Type=='MIO_3T_sec', N=='1000') %>% group_by(P,T,Sigma,Scenario_Type) %>% summarize(mean.value=mean(Accuracy),max.value=max(Accuracy),min.value=min(Accuracy))

plot_3 = ggplot(data = MIO_Data,
                aes(x=Sigma,
                    y=mean.value,
                    color=Scenario_Type)) +
  geom_line(size = 0.9) +
  facet_grid(P~T, labeller=label_both) +
  ggtitle(paste('Mean MIO Accuracy vs Sigma by Scenario Type')) +
  theme(axis.text=element_text(size=16),
        axis.title=element_text(size=18,face='bold'),
        plot.title=element_text(size = rel(2)),
        legend.text=element_text(size=14),
        legend.title=element_text(size=14),
        strip.text.x=element_text(size = 14),
        strip.text.y=element_text(size = 14)) +
  xlab('Sigma') +
  ylab('% of Correctly Labelled Detections') + 
  scale_fill_discrete(name = '') + 
  theme(legend.position = "bottom") 

Save_str = 'Plots/Accuracy/vs_Sigma_MIO_by_Scenario_Type.png'
png(file=Save_str,width=1000, height=700)
print(plot_3)
dev.off()

####################################
###                              ###
###  MIO Accuracy vs Sigma By N  ###
###                              ###
####################################

MIO_Data2 = Data %>% filter(Solution_Type=='MIO_3T_sec') %>% group_by(P,T,Sigma,N) %>% summarize(mean.value=mean(Accuracy),max.value=max(Accuracy),min.value=min(Accuracy))

plot_4 = ggplot(data = MIO_Data2,
                aes(x=Sigma,
                    y=mean.value,
                    color=N)) +
  geom_line(size = 0.9) +
  facet_grid(P~T, labeller=label_both) +
  ggtitle(paste('Mean MIO Accuracy vs Sigma by Number of Heuristic Starting Points (N)')) +
  theme(axis.text=element_text(size=16),
        axis.title=element_text(size=18,face='bold'),
        plot.title=element_text(size = rel(2)),
        legend.text=element_text(size=14),
        legend.title=element_text(size=14),
        strip.text.x=element_text(size = 14),
        strip.text.y=element_text(size = 14)) +
  xlab('Sigma') +
  ylab('% of Correctly Labelled Detections') +
  theme(legend.position = "bottom") 

Save_str = 'Plots/Accuracy/vs_Sigma_MIO_by_N.png'
png(file=Save_str,width=1000, height=700)
print(plot_4)
dev.off()


Rho_Data = Data %>% filter(Rho_Type=='Proximity', Solution_Type != 'Ideal')
Rho_Data$Solution_Type = factor(Rho_Data$Solution_Type)
  
##########################################
###                                    ###
###  Accuracy vs Rho By Solution Type  ###
###                                    ###
##########################################
  
Rho_Data2 = Rho_Data %>% filter(Solution_Type!='MIO_3T_sec', N=='1000') %>% group_by(P,T,Rho,Solution_Type) %>% summarize(mean.value=mean(Accuracy),max.value=max(Accuracy),min.value=min(Accuracy))

Labels = c('Random',
           'Heuristic',
           'MIO (1sec)',
           'MIO (Tsec)',
           'MIO (2T sec)')

plot_5 = ggplot(data = Rho_Data2,
                aes(x=Rho,
                    y=mean.value,
                    color=Solution_Type)) +
  geom_line(size = 0.9) +
  facet_grid(P~T, labeller=label_both) +
  ggtitle(paste('Mean Accuracy vs Rho by Solution Type')) +
  theme(axis.text=element_text(size=16),
        axis.title=element_text(size=18,face='bold'),
        plot.title=element_text(size = rel(2)),
        legend.text=element_text(size=14),
        legend.title=element_text(size=14),
        strip.text.x=element_text(size = 14),
        strip.text.y=element_text(size = 14)) +
  xlab('Rho') +
  ylab('% of Correctly Labelled Detections') +
  scale_color_manual(name = '',
                     values=group.colors[1:5], 
                     labels=Labels) + 
  theme(legend.position = "bottom") 
  
Save_str = 'Plots/Accuracy/vs_Rho_Solution_Type.png'
png(file=Save_str,width=1000, height=700)
print(plot_5)
dev.off()
  
########################################
###                                  ###
###  Heuristic Accuracy vs Rho By N  ###
###                                  ###
########################################
  
Heuristic_Data = Rho_Data%>%filter(Solution_Type=='Heuristic') %>% group_by(P,T,Rho,N) %>% summarize(mean.value=mean(Accuracy),max.value=max(Accuracy),min.value=min(Accuracy))
  
plot_6 = ggplot(data = Heuristic_Data,
                aes(x=Rho,
                    y=mean.value,
                    color=N)) +
  geom_line(size = 0.9) +
  facet_grid(P~T, labeller=label_both) +
  ggtitle(paste('Mean Heuristic Accuracy vs Rho by Number of Starting Points (N)')) +
  theme(axis.text=element_text(size=16),
        axis.title=element_text(size=18,face='bold'),
        plot.title=element_text(size = rel(2)),
        legend.text=element_text(size=14),
        legend.title=element_text(size=14),
        strip.text.x=element_text(size = 14),
        strip.text.y=element_text(size = 14)) +
  xlab('Rho') +
  ylab('% of Correctly Labelled Detections') + 
  theme(legend.position = "bottom") 
  
Save_str = 'Plots/Accuracy/vs_Rho_Heuristic_by_N.png'
png(file=Save_str,width=1000, height=700)
print(plot_6)
dev.off()
  
##############################################
###                                        ###
###  MIO Accuracy vs Rho By Scenario Type  ###
###                                        ###
##############################################
  
MIO_Data = Rho_Data %>% filter(Solution_Type=='MIO_3T_sec', N=='1000') %>% group_by(P,T,Rho,Scenario_Type) %>% summarize(mean.value=mean(Accuracy),max.value=max(Accuracy),min.value=min(Accuracy))
  
plot_7 = ggplot(data = MIO_Data,
                aes(x=Rho,
                    y=mean.value,
                    color=Scenario_Type)) +
  geom_line(size = 0.9) +
  facet_grid(P~T, labeller=label_both) +
  ggtitle(paste('Mean MIO Accuracy vs Rho by Scenario Type')) +
  theme(axis.text=element_text(size=16),
        axis.title=element_text(size=18,face='bold'),
        plot.title=element_text(size = rel(2)),
        legend.text=element_text(size=14),
        legend.title=element_text(size=14),
        strip.text.x=element_text(size = 14),
        strip.text.y=element_text(size = 14)) +
  xlab('Rho') +
  ylab('% of Correctly Labelled Detections') + 
  scale_color_manual(name = '') + 
  theme(legend.position = "bottom") 
  
Save_str = 'Plots/Accuracy/vs_Rho_MIO_by_Scenario_Type.png'
png(file=Save_str,width=1000, height=700)
print(plot_7)
dev.off()
  
##################################
###                            ###
###  MIO Accuracy vs Rho By N  ###
###                            ###
##################################
  
MIO_Data2 = Rho_Data %>% filter(Solution_Type=='MIO_3T_sec')  %>% group_by(P,T,Rho,N) %>% summarize(mean.value=mean(Accuracy),max.value=max(Accuracy),min.value=min(Accuracy))
  
plot_8 = ggplot(data = MIO_Data2,
                aes(x=Rho,
                    y=mean.value,
                    color=N)) +
  geom_line(size = 0.9) +
  facet_grid(P~T, labeller=label_both) +
  ggtitle(paste('Mean MIO Accuracy vs Rho by Number of Heuristic Starting Points (N)')) +
  theme(axis.text=element_text(size=16),
        axis.title=element_text(size=18,face='bold'),
        plot.title=element_text(size = rel(2)),
        legend.text=element_text(size=14),
        legend.title=element_text(size=14),
        strip.text.x=element_text(size = 14),
        strip.text.y=element_text(size = 14)) +
    xlab('Rho') +
  ylab('% of Correctly Labelled Detections') + theme(legend.position = "bottom") 
  
Save_str = 'Plots/Accuracy/vs_Rho_MIO_by_N.png'
png(file=Save_str,width=1000, height=700)
print(plot_8)
dev.off()
