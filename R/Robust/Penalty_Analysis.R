setwd("~/Desktop/Results/Robust/")

Data = read.csv('Files/Summary.csv', 
                header=TRUE, 
                stringsAsFactors=TRUE)

Data$P             = factor(Data$P)
Data$Scenario_num  = factor(Data$Scenario_num)
Data$Test_P        = factor(Data$Test_P)
Data$Sim_num       = factor(Data$Sim_num)
Data$MIO_Time      = factor(Data$MIO_Time)
Data$Solution_Type = factor(Data$Solution_Type, 
                            levels = c('Ideal',
                                       'Random',
                                       'Heuristic',
                                       'Optimized'))

DataOpt1 = Data %>% filter(Solution_Type=='Optimized',
                           MIO_Time==1) %>% mutate(Solution_Type='MIO_1_sec')
DataOpt2 = Data %>% filter(Solution_Type=='Optimized',
                           MIO_Time==T) %>% mutate(Solution_Type='MIO_T_sec')
DataOpt3 = Data %>% filter(Solution_Type=='Optimized',
                           MIO_Time==2*T) %>% mutate(Solution_Type='MIO_2T_sec')
DataOpt4 = Data %>% filter(Solution_Type=='Optimized',
                           MIO_Time==3*T) %>% mutate(Solution_Type='MIO_3T_sec')

Data_subset = Data %>% filter(Solution_Type!='Optimized')

DataSummary = rbind(Data_subset,DataOpt1,DataOpt2,DataOpt3,DataOpt4)

DataSummary$T = factor(DataSummary$T)
DataSummary$Solution_Type = factor(DataSummary$Solution_Type,
                                   levels = c('Random',
                                              'Heuristic',
                                              'MIO_1_sec',
                                              'MIO_T_sec',
                                              'MIO_2T_sec',
                                              'MIO_3T_sec',
                                              'Ideal'))

DataSummary$Test_P = factor(DataSummary$Test_P)

Temp = Temp %>% filter(P=="4", T=="4",Sigma == 0.1)

Temp = DataSummary  %>% filter(Solution_Type == "MIO_3T_sec") %>% mutate(P_diff=abs(as.numeric(P)-as.numeric(Test_P))) %>% group_by(P,T,Scenario_num,Sigma,Gamma,Lambda,Sim_num,Theta,Phi,Solution_Type) %>% filter(min_rank(Objective) <= 1) %>% filter(min_rank(desc(Accuracy)) <= 1) %>% filter(min_rank(Delta)<=1) %>% filter(min_rank(P_diff) <= 1) %>% ungroup()  %>% mutate(phi_theta=paste(Phi,Theta,sep="_")) 


%>% filter(Solution_Type == "MIO_3T_sec") %>% filter( T=="10",Sigma == 0.1) 

AccuSummary=Temp %>% group_by(P,T,Scenario_num,Sim_num,Sigma,Gamma,Lambda,Solution_Type) %>% summarize(min_acc=min(Accuracy),max_acc=max(Accuracy))

Temp2 = Temp %>% group_by(P,T,Scenario_num,Sim_num,Sigma,Gamma,Lambda,Solution_Type) %>% filter(min_rank(desc(Accuracy)) <= 1) %>% filter(min_rank(P_diff) <= 1) %>% filter(min_rank(Delta)<=1) %>% filter(min_rank(Objective) <= 1)%>% ungroup() #%>% filter(Accuracy >= 0.95)

Temp3= Temp %>% group_by(P,T,Scenario_num,Sigma,Gamma,Lambda,Sim_num,Solution_Type) %>% filter(min_rank(Delta) <= 1) %>% ungroup()

plot = ggplot(data = Temp2,
              aes(phi_theta)) +
  geom_bar(stat=) +
  facet_grid(Gamma~Lambda, labeller=label_both) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

Save_str = 'Plots/Penalties_sigma.1.png'
png(file=Save_str,width=1000, height=700)
print(plot)
dev.off()

plot = ggplot(data = Temp3,
       aes(phi_theta)) +
  geom_bar() +
  facet_grid(Gamma~Lambda, labeller=label_both) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

Save_str = 'Plots/Penalties_2.png'
png(file=Save_str,width=1000, height=700)
print(plot)
dev.off()

ggplot(data = Temp,
       aes(Accuracy)) +
  geom_histogram()




Heuristic_Data = Data%>%filter(Solution_Type!='Ideal') %>% group_by(P,T,Sigma,N) %>% summarize(mean.value=mean(Accuracy),max.value=max(Accuracy),min.value=min(Accuracy))


