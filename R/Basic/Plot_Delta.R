library(ggplot2)
library(dplyr)
library(tidyr)
library(RColorBrewer)

setwd('~/Desktop/Results/Basic/')

Raw_Data = read.csv('Files/Delta.csv',
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

#########################################
###                                   ###
###  Delta vs Sigma By Solution Type  ###
###                                   ###
#########################################

Sigma_Data = Data %>% filter(Solution_Type!='MIO_3T_sec', N == '1000') %>% group_by(P,T,Sigma,Solution_Type) %>% summarize(mean.value=mean(Delta),max.value=max(Delta),min.value=min(Delta))

Sigma_Data$Solution_Type = factor(Sigma_Data$Solution_Type)

Labels = c('Random',
           'Heuristic',
           'MIO (1 sec)',
           'MIO (T sec)',
           'MIO (2T sec)',
           'Ideal')

plot_1 = ggplot(data = Sigma_Data,
                aes(x=Sigma,
                    y=mean.value,
                    color=Solution_Type)) +
  geom_line(size = 0.9) +
  facet_grid(P~T, labeller=label_both) +
  ggtitle(paste('Mean Delta vs Sigma by Solution Type')) +
  theme(axis.text=element_text(size=rel(2)),
        axis.title=element_text(size=rel(3),face='bold'),
        plot.title=element_text(size = rel(3),face='bold'),
        legend.text=element_text(size=rel(3)),
        legend.key.height=unit(2,"line"),
        strip.text.x=element_text(size = rel(3)),
        strip.text.y=element_text(size = rel(3))) + 
  xlab('Sigma') +
  ylab('Delta') +
  theme(legend.position = "bottom") + 
  scale_color_manual(name = '', 
                     values=group.colors, 
                     labels=Labels) + 
  guides(colour = guide_legend(override.aes = list(size=4)))

Save_str = 'Plots/LaTeX/Basic_Delta_Summary.pdf'
pdf(file=Save_str, width = 14, height = 12)
print(plot_1)
dev.off()

# #######################################
# ###                                 ###
# ###  Heuristic Delta vs Sigma By N  ###
# ###                                 ###
# #######################################
# Heuristic_Data = Data%>%filter(Solution_Type=='Heuristic') %>% group_by(P,T,Sigma,N) %>% summarize(mean.value=mean(Delta),max.value=max(Delta),min.value=min(Delta))
# 
# plot_2 = ggplot(data = Heuristic_Data,
#                 aes(x=Sigma,
#                     y=mean.value,
#                     color=N)) +
#   geom_line(size = 0.9) +
#   facet_grid(P~T, labeller=label_both) +
#   ggtitle(paste('Mean Heuristic Delta vs Sigma by N')) +
#   theme(axis.text=element_text(size=16),
#         axis.title=element_text(size=18,face='bold'),
#         plot.title=element_text(size = rel(2)),
#         legend.text=element_text(size=14),
#         legend.title=element_text(size=14),
#         strip.text.x=element_text(size = 14),
#         strip.text.y=element_text(size = 14)) +
#   xlab('Sigma') +
#   ylab('Delta')
# 
# Save_str = 'Plots/Delta/vs_Sigma_Heuristic_by_N.png'
# png(file=Save_str,width=1000, height=700)
# print(plot_2)
# dev.off()
# 
# #############################################
# ###                                       ###
# ###  MIO Delta vs Sigma By Scenario Type  ###
# ###                                       ###
# #############################################
# 
# MIO_Data = Data %>% filter(Solution_Type=='MIO_3T_sec', N=='1000') %>% group_by(P,T,Sigma,Scenario_Type) %>% summarize(mean.value=mean(Delta),max.value=max(Delta),min.value=min(Delta))
# 
# plot_3 = ggplot(data = MIO_Data,
#                 aes(x=Sigma,
#                     y=mean.value,
#                     color=Scenario_Type)) +
#   geom_line(size = 0.9) +
#   facet_grid(P~T, labeller=label_both) +
#   ggtitle(paste('Mean MIO Delta vs Sigma by Scenario Type')) +
#   theme(axis.text=element_text(size=16),
#         axis.title=element_text(size=18,face='bold'),
#         plot.title=element_text(size = rel(2)),
#         legend.text=element_text(size=14),
#         legend.title=element_text(size=14),
#         strip.text.x=element_text(size = 14),
#         strip.text.y=element_text(size = 14)) +
#   xlab('Sigma') +
#   ylab('Delta')
# 
# Save_str = 'Plots/Delta/vs_Sigma_MIO_by_Scenario_Type.png'
# png(file=Save_str,width=1000, height=700)
# print(plot_3)
# dev.off()
# 
# #################################
# ###                           ###
# ###  MIO Delta vs Sigma By N  ###
# ###                           ###
# #################################
# 
# MIO_Data2 = Data %>% filter(Solution_Type=='MIO_3T_sec') %>% group_by(P,T,Sigma,N) %>% summarize(mean.value=mean(Delta),max.value=max(Delta),min.value=min(Delta))
# 
# plot_4 = ggplot(data = MIO_Data2,
#                 aes(x=Sigma,
#                     y=mean.value,
#                     color=N)) +
#   geom_line(size = 0.9) +
#   facet_grid(P~T, labeller=label_both) +
#   ggtitle(paste('Mean MIO Delta vs Sigma by N')) +
#   theme(axis.text=element_text(size=16),
#         axis.title=element_text(size=18,face='bold'),
#         plot.title=element_text(size = rel(2)),
#         legend.text=element_text(size=14),
#         legend.title=element_text(size=14),
#         strip.text.x=element_text(size = 14),
#         strip.text.y=element_text(size = 14)) +
#   xlab('Sigma') +
#   ylab('Delta')
# 
# Save_str = 'Plots/Delta/vs_Sigma_MIO_by_N.png'
# png(file=Save_str,width=1000, height=700)
# print(plot_4)
# dev.off()
#   
# Rho_Data = Data %>% filter(Rho_Type=='Proximity', Solution_Type != 'Ideal')
# Rho_Data$Solution_Type = factor(Rho_Data$Solution_Type)
#   
# #######################################
# ###                                 ###
# ###  Delta vs Rho By Solution Type  ###
# ###                                 ###
# #######################################
#   
# Rho_Data2 = Rho_Data %>% filter(Solution_Type!='MIO_3T_sec', N=='1000') %>% group_by(P,T,Rho,Solution_Type) %>% summarize(mean.value=mean(Delta),max.value=max(Delta),min.value=min(Delta))
#   
# plot_5 = ggplot(data = Rho_Data2,
#                 aes(x=Rho,
#                     y=mean.value,
#                     color=Solution_Type)) +
#   geom_line(size = 0.9) +
#   facet_grid(P~T, labeller=label_both) +
#   ggtitle(paste('Mean Delta vs Rho by Solution Type')) +
#   theme(axis.text=element_text(size=16),
#         axis.title=element_text(size=18,face='bold'),
#         plot.title=element_text(size = rel(2)),
#         legend.text=element_text(size=14),
#         legend.title=element_text(size=14),
#         strip.text.x=element_text(size = 14),
#         strip.text.y=element_text(size = 14)) +
#   xlab('Rho') +
#   ylab('Delta') +
#   scale_color_manual(values=group.colors)
#   
# Save_str = 'Plots/Delta/vs_Rho_Solution_Type.png'
# png(file=Save_str,width=1000, height=700)
# print(plot_5)
# dev.off()
#   
# #####################################
# ###                               ###
# ###  Heuristic Delta vs Rho By N  ###
# ###                               ###
# #####################################
#   
# Heuristic_Data = Rho_Data%>%filter(Solution_Type=='Heuristic') %>% group_by(P,T,Rho,N) %>% summarize(mean.value=mean(Delta),max.value=max(Delta),min.value=min(Delta))
#   
# plot_6 = ggplot(data = Heuristic_Data,
#                 aes(x=Rho,
#                     y=mean.value,
#                     color=N)) +
#   geom_line(size = 0.9) +
#   facet_grid(P~T, labeller=label_both) +
#   ggtitle(paste('Mean Heuristic Delta vs Rho by N')) +
#   theme(axis.text=element_text(size=16),
#         axis.title=element_text(size=18,face='bold'),
#         plot.title=element_text(size = rel(2)),
#         legend.text=element_text(size=14),
#         legend.title=element_text(size=14),
#         strip.text.x=element_text(size = 14),
#         strip.text.y=element_text(size = 14)) +
#   xlab('Rho') +
#   ylab('Delta')
#  
# Save_str = 'Plots/Delta/vs_Rho_Heuristic_by_N.png'
# png(file=Save_str,width=1000, height=700)
# print(plot_6)
# dev.off()
#   
# ###########################################
# ###                                     ###
# ###  MIO Delta vs Rho By Scenario Type  ###
# ###                                     ###
# ###########################################
#   
# MIO_Data = Rho_Data %>% filter(Solution_Type=='MIO_3T_sec', N=='1000') %>% group_by(P,T,Rho,Scenario_Type) %>% summarize(mean.value=mean(Delta),max.value=max(Delta),min.value=min(Delta))
#   
# plot_7 = ggplot(data = MIO_Data,
#                 aes(x=Rho,
#                     y=mean.value,
#                     color=Scenario_Type)) +
#   geom_line(size = 0.9) +
#   facet_grid(P~T, labeller=label_both) +
#   ggtitle(paste('Mean MIO Delta vs Rho by Scenario Type')) +
#   theme(axis.text=element_text(size=16),
#         axis.title=element_text(size=18,face='bold'),
#         plot.title=element_text(size = rel(2)),
#         legend.text=element_text(size=14),
#         legend.title=element_text(size=14),
#         strip.text.x=element_text(size = 14),
#         strip.text.y=element_text(size = 14)) +
#   xlab('Rho') +
#   ylab('Delta')
#   
# Save_str = 'Plots/Delta/vs_Rho_MIO_by_Scenario_Type.png'
# png(file=Save_str,width=1000, height=700)
# print(plot_7)
# dev.off()
#   
# ###############################
# ###                         ###
# ###  MIO Delta vs Rho By N  ###
# ###                         ###
# ###############################
#   
# MIO_Data2 = Rho_Data %>% filter(Solution_Type=='MIO_3T_sec', N=='1000')  %>% group_by(P,T,Rho,N) %>% summarize(mean.value=mean(Delta),max.value=max(Delta),min.value=min(Delta))
#   
# plot_8 = ggplot(data = MIO_Data2,
#                 aes(x=Rho,
#                     y=mean.value,
#                     color=N)) +
#   geom_line(size = 0.9) +
#   facet_grid(P~T, labeller=label_both) +
#   ggtitle(paste('Mean MIO Delta vs Rho by N')) +
#   theme(axis.text=element_text(size=16),
#         axis.title=element_text(size=18,face='bold'),
#         plot.title=element_text(size = rel(2)),
#         legend.text=element_text(size=14),
#         legend.title=element_text(size=14),
#         strip.text.x=element_text(size = 14),
#         strip.text.y=element_text(size = 14)) +
#   xlab('Rho') +
#   ylab('Delta')
#   
# Save_str = 'Plots/Delta/vs_Rho_MIO_by_N.png'
# png(file=Save_str,width=1000, height=700)
# print(plot_8)
# dev.off()
