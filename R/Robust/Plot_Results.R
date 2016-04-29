library(ggplot2)
library(dplyr)
library(tidyr)
library(RColorBrewer)

setwd('~/Desktop/Results/Robust/')

Raw_Data = read.csv('Files/Results_summary.csv', 
                    header=TRUE, 
                    stringsAsFactors=TRUE)

Raw_Data$P             = factor(Raw_Data$P)
Raw_Data$Scenario_num  = factor(Raw_Data$Scenario_num)
Raw_Data$Gamma         = 1 - Raw_Data$Gamma
Raw_Data$Gamma         = factor(Raw_Data$Gamma,
                                levels = c(0.05,0.1,0.15,0.2))
                                                      
Raw_Data$Lambda        = factor(Raw_Data$Lambda)
Raw_Data$Sim_num       = factor(Raw_Data$Sim_num)
Raw_Data$Test_P        = factor(Raw_Data$Test_P)

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
Data$MIO_Time = NULL

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
               'MIO_3T_sec',
               'Ideal')

group.colors = brewer.pal(7, 'Set2')

Labels = c('Random',
           'Heuristic',
           'MIO (1 sec)',
           'MIO (T sec)',
           'MIO (2T sec)',
           'Ideal')

Data_new = Data %>% group_by(P, T, Scenario_num, Sigma, Gamma, Lambda, Sim_num, Theta, Phi, Solution_Type) %>% filter(min_rank(Objective) <= 1) %>% ungroup()

###########################################
###                                     ###
###  TEST P HISTOGRAM BY SOLUTION TYPE  ###
###                                     ###
###########################################
Temp = Data_new
Temp$P = as.numeric(as.character(Temp$P))
Temp$Test_P = as.numeric(as.character(Temp$Test_P))
Temp$Diff_P = Temp$P - Temp$Test_P
Temp$Diff_P = factor(Temp$Diff_P)
Temp$P = factor(Temp$P)

Temp2= Temp%>% group_by(T,P,Gamma,Lambda,Diff_P,Solution_Type) %>% summarize(count=n())

Labels = c('Random', 'Heuristic', 'MIO')

P_range = c(4, 6, 8, 10)
T_range = c(4, 6, 8, 10)

for (P_loop in P_range){
  for (T_loop in T_range){
    Data3 = Temp2 %>% filter(P==P_loop,T==T_loop,Solution_Type!='MIO_3T_sec', Solution_Type!='Ideal', Solution_Type!='MIO_1_sec',Solution_Type!='MIO_T_sec') 
    Data3$P = factor(Data3$P)
    Data3$T = factor(Data3$T)
    Data3$Diff_P = factor(Data3$Diff_P)
    Data3$Solution_Type = factor(Data3$Solution_Type)
    
    Data3=rbind(Data3,cbind(expand.grid(P=levels(Data3$P),T=levels(Data3$T),Gamma=levels(Data3$Gamma),Lambda=levels(Data3$Lambda),Diff_P=levels(Data3$Diff_P),Solution_Type=levels(Data3$Solution_Type)),count=NA))
  
    plot = ggplot(data = Data3, aes(x=Diff_P, y=count, fill=Solution_Type)) + geom_bar(stat = "Identity",position="dodge",colour='black') + facet_grid(Gamma~Lambda, labeller=label_both) + ggtitle(expression(paste('Frequency of ', P[difference]))) +
  theme(axis.text=element_text(size=16),
        axis.title=element_text(size=18,face='bold'),
        plot.title=element_text(size = rel(2)),
        legend.text=element_text(size=14),
        legend.title=element_text(size=14),
        strip.text.x=element_text(size = 14),
        strip.text.y=element_text(size = 14)) + 
  ylab('Number of Occurences') + 
  xlab(expression(P[difference])) + scale_fill_discrete("Solution Type",labels=Labels)
    
    Save_str = paste('Plots/Histogram/',toString(P_loop),'_', 
                     toString(T_loop),'_Histogram.png', sep='')
    png(file=Save_str,width=1000, height=700)
    print(plot)
    dev.off()
  }
}


##########################################
###                                    ###
###  Accuracy vs Rho By Solution Type  ###
###                                    ###
##########################################
Labels = c('Random',
           'Heuristic',
           'MIO (1 sec)',
           'MIO (T sec)',
           'MIO (2T sec)')

P_range = c(4, 6, 8, 10)
T_range = c(4, 6, 8, 10)

for (P_loop in P_range){
  for (T_loop in T_range){

Data2 = Data_new %>% filter(P==as.character(P_loop),T==as.character(T_loop),Solution_Type!='Ideal', Solution_Type!='MIO_3T_sec') %>% group_by(Gamma,Lambda,Rho,Solution_Type) %>% summarize(mean.value=mean(Accuracy),max.value=max(Accuracy),min.value=min(Accuracy))

Data2$Solution_Type = factor(Data2$Solution_Type)

plot = ggplot(data = Data2,
                aes(x=Rho,
                    y=mean.value,
                    color=Solution_Type)) +
  geom_line(size = 0.9) +
  facet_grid(Gamma~Lambda, labeller=label_both) +
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
  scale_color_manual(name = 'Solution Type',
                     values=group.colors, 
                     labels=Labels) + 
  scale_y_continuous(limits = c(0, 1.0))

Save_str = paste('Plots/Accuracy/',toString(P_loop),'_', 
                 toString(T_loop),'_Accuracy.png', sep='')
png(file=Save_str,width=1000, height=700)
print(plot)
dev.off()
  }
}

#########################################
###                                   ###
###  Delta vs Sigma By Solution Type  ###
###                                   ###
#########################################

Labels = c('Random',
           'Heuristic',
           'MIO (1 sec)',
           'MIO (T sec)',
           'MIO (2T sec)',
           'Ideal')

P_range = c(4, 6, 8, 10)
T_range = c(4, 6, 8, 10)

for (P_loop in P_range){
  for (T_loop in T_range){
    
Sigma_Data = Data %>% filter(P==as.character(P_loop),T==as.character(T_loop),Solution_Type!='MIO_3T_sec') %>% group_by(Gamma,Lambda,Sigma,Solution_Type) %>% summarize(mean.value=mean(Delta),max.value=max(Delta),min.value=min(Delta))

Sigma_Data$Solution_Type = factor(Sigma_Data$Solution_Type)

plot_2 = ggplot(data = Sigma_Data,
                aes(x=Sigma,
                    y=mean.value,
                    color=Solution_Type)) +
  geom_line(size = 0.9) +
  facet_grid(Gamma~Lambda, labeller=label_both) +
  ggtitle(paste('Mean Delta vs Sigma by Solution Type')) +
  theme(axis.text=element_text(size=16),
        axis.title=element_text(size=18,face='bold'),
        plot.title=element_text(size = rel(2)),
        legend.text=element_text(size=14),
        legend.title=element_text(size=14),
        strip.text.x=element_text(size = 14),
        strip.text.y=element_text(size = 14)) +
  xlab('Sigma') +
  ylab('Delta') +
  scale_color_manual(name = 'Solution Type', 
                     values=group.colors, 
                     labels=Labels)

Save_str = paste('Plots/Delta/',toString(P_loop),'_', 
                 toString(T_loop),'_Delta.png', sep='')
png(file=Save_str,width=1000, height=700)
print(plot_2)
dev.off()
  }
}
