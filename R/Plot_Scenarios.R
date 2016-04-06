library(ggplot2)
library(dplyr)
library(tidyr)

setwd("~/Documents/Academic/Research/Git/Multi-Target-Tracking/Julia/Basic/")

P_range = c(4,6,8,10)
T_range = c(4,6,8,10)

Num_scenarios = 10

for (P in P_range){
for (T in T_range){
for (Scenario_num in 1:Num_scenarios){
      
read_path=paste("R_Files/True_Positions/", toString(P),"\\", toString(T),
                "\\", toString(Scenario_num), ".csv", sep="")
    
Data = read.csv(read_path, header = FALSE)

Title_str = paste("True Trajectories of Scenario", toString(Scenario_num))
  
plot = ggplot(Summary,aes(x=Time,y=Position,color=Target_ID))+geom_line()+ ggtitle(Title_str)+theme(axis.text=element_text(size=16),axis.title=element_text(size=18,face="bold"),plot.title=element_text(size = rel(2)),legend.text=element_text(size=14),legend.title=element_text(size=14),strip.text.x=element_text(size = 14),strip.text.y=element_text(size = 14))+xlab("Time")+ylab("Position")
      
Save_path = paste("Scenario_Plots/True_Trajectories/",toString(P),"\\",toString(T),"\\",toString(Scenario_num),".png",sep="")
      
png(file=Save_path,width=1000, height=700)
print(plot)
dev.off()
}}}

