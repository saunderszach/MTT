library(ggplot2)
library(dplyr)
library(tidyr)

setwd("~/Documents/Academic/Research/Git/Multi-Target-Tracking")

P_range = c(4,6,8,10)
T_range = c(4,6,8,10)
Num_scenarios = 2
Num_sims = 2
Sigma_range = seq(0.3,0.5,0.1)
N_range = c(100, 1000, 10000)
Types = c("original", "alternate")


for (type in Types){
Data_Summary  = data.frame(P                = factor(),
                           T                = factor(),
                           Scenario_num     = factor(),
                           Sim_num          = factor(),
                           Sigma            = factor(),
                           N                = factor(),
                           Time             = double(), 
                           Objective        = double(), 
                           Best_bound       = double())
for (P in P_range){
for (T in T_range){
for (Scenario_num in 1:Num_scenarios){
for (Sim_num in 1:Num_sims){
for (Sigma in Sigma_range){
for (N in N_range){ 
  
Sigma = format(Sigma, nsmall=1)

str=paste("Julia/Basic/Experiment/MIP_Summaries/",                
          toString(P), "\\", 
          toString(T), "\\", 
          toString(Scenario_num), "\\",
          toString(Sim_num), "\\",
          toString(Sigma), "\\", 
          toString(N), "_", type, ".csv", sep="")
        
Raw_Data=read.csv(str,header=TRUE)
        
#Define the initial time 
Time_intial = Raw_Data$time[1]
        
#Convert the raw time to actual time (in seconds)
Time = (Raw_Data$time - Time_intial)/1e9
      
Objective = Raw_Data$objective
Best_bound = Raw_Data$bestbound

#Build a temporary data frame
Data_Temp = data.frame(Time, Objective, Best_bound)  

#Add factor variables
Data_Temp=Data_Temp%>%mutate(P             = as.factor(P), 
                             T             = as.factor(T), 
                             Scenario_num  = as.factor(Scenario_num),
                             Sim_num       = as.factor(Sim_num),
                             Sigma         = as.factor(Sigma),
                             N             = as.factor(N))

#Add to the full data summary
Data_Summary=rbind(Data_Summary,Data_Temp)

}}}}}}
  
#Save to a file
Write_str = paste("Results/Files/MIP_", type,".csv", sep="")
write.csv(file = Write_str, Data_Summary)
}

library(ggplot2)
library(dplyr)
library(tidyr)

setwd("~/Documents/Academic/Research/Git/Multi-Target-Tracking/Results")

Original = read.csv("Files/MIP_original.csv", header = TRUE)
Alternate = read.csv("Files/MIP_alternate.csv", header = TRUE)

Original=Original%>%mutate(Type = "Original")
Alternate=Alternate%>%mutate(Type = "Alternate")

Combined=rbind(Original,Alternate)
Combined$X = NULL

Combined$P             = factor(Combined$P) 
Combined$T             = factor(Combined$T)
Combined$Scenario_num  = factor(Combined$Scenario_num)
Combined$Sim_num       = factor(Combined$Sim_num)
Combined$Sigma         = factor(Combined$Sigma)
Combined$N             = factor(Combined$N)
Combined$Type          = factor(Combined$Type)

Combined=Combined%>% group_by(P,T,Scenario_num,Sim_num,Sigma) %>% mutate(best_found=min(Objective)) %>% ungroup %>% mutate(Percent_Optimal=Objective/best_found,Percent_Bound=Best_bound/best_found) %>% select(-Objective,-best_found,-Best_bound)

Max_time = 300

Time_seq = c(seq(0,1.0,.1),seq(2,Max_time,1))

MIP_Times = data.frame(P                =  factor(),
                       T                =  factor(),
                       Scenario_num     =  factor(),
                       Sim_num          =  factor(),
                       Sigma            =  factor(),
                       N                =  factor(),
                       Type             =  factor(),
                       Time             =  double(), 
                       Min_objective    =  double(),
                       Mean_objective   =  double(),
                       Max_objective    =  double(),
                       Min_bound        =  double(),
                       Mean_bound       =  double(),
                       Max_bound        =  double())

for (t in Time_seq){
 
Data_Temp=Combined %>% filter(Time<=t) %>% group_by(P,T,Scenario_num,Sim_num,Sigma,N,Type) %>% filter(min_rank(desc(Time)) <=1) %>% mutate(Time=t) %>% ungroup() %>% group_by(P,T,Type,Time,N,Sigma) %>% summarize(Mean_objective=mean(Percent_Optimal),Max_objective=max(Percent_Optimal),Min_objective=min(Percent_Optimal),Mean_bound=mean(Percent_Bound),Max_bound=max(Percent_Bound),Min_bound=min(Percent_Bound),NumberSims=n()) %>% ungroup()
  
MIP_Times=rbind(MIP_Times,Data_Temp)
}

MIP_Times=as.data.frame(MIP_Times)

write.csv(file = "Files/MIP_Times.csv", MIP_Times)

###################################################################
library(ggplot2)
library(dplyr)
library(tidyr)

MIP_Times = read.csv("~/Desktop/MIP_comparisons/MIP_Times.csv")

MIP_Times2 = MIP_Times%>%filter(P=="4",T=="4")

plot_1 = ggplot(data=MIP_Times2,
                aes(x=Time,
                    y=Mean_objective,
                    color=Type)) +
  geom_line() +
  facet_grid(Sigma~N, labeller=label_both) +  
  ggtitle(paste("MIO Performance: Average Objective versus Time (4 x 4)")) + 
  theme(axis.text=element_text(size=16),
        axis.title=element_text(size=18,face="bold"),
        plot.title=element_text(size = rel(2)),
        legend.text=element_text(size=14),
        legend.title=element_text(size=14),
        strip.text.x=element_text(size = 14),
        strip.text.y=element_text(size = 14)) +
  xlab("Elapsed Time") +
  ylab("% of Optimal Objective") +
  #scale_y_log10() + 
  scale_x_log10() + 
  geom_ribbon(aes(x=Time,ymin=Min_objective,ymax=Max_objective, fill=Type),alpha=0.3)

Save_str = paste("~/Desktop/MIP_Comparisons/4x4_objective.png", sep="")
png(file=Save_str,width=1000, height=700)
print(plot_1)
dev.off()

plot_2 = ggplot(data=MIP_Times2,
                aes(x=Time, 
                y=Mean_bound,
                color=Type)) +
  geom_line() +
  facet_grid(Sigma~N, labeller=label_both) +  
  ggtitle(paste("MIO Performance: Average Bound versus Time (4 x 4)")) + 
  theme(axis.text=element_text(size=16),
        axis.title=element_text(size=18,face="bold"),
        plot.title=element_text(size = rel(2)),
        legend.text=element_text(size=14),
        legend.title=element_text(size=14),
        strip.text.x=element_text(size = 14),
        strip.text.y=element_text(size = 14)) +
  xlab("Elapsed Time") +
  ylab("% of Optimal") +
  ylim(0,1)+
  #scale_y_log10() + 
  scale_x_log10()

Save_str = paste("~/Desktop/MIP_Comparisons/4x4_bound.png", sep="")
png(file=Save_str,width=1000, height=700)
print(plot_2)
dev.off()
  