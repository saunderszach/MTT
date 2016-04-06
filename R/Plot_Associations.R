library(ggplot2)
library(dplyr)
library(tidyr)

setwd("~/Documents/Academic/Research/Git/Multi-Target-Tracking/Julia/Basic/")

Types = c("Ideal", "Heuristic", "MIO")
P_range = c(4,6,8,10)
T_range = c(4,6,8,10)
Num_scenarios = 10
Num_sims = 3
Sigma_range = seq(0.1,2.0,0.1)
N_range = c(100, 1000, 10000)

for (P in P_range){
for (T in T_range){
  MIO_Times = c(1,T,2*T,3*T)
for (Scenario_num in 1:Num_scenarios){
for (Sim_num in 1:Num_sims){
for (Sigma in Sigma_range){
for (N in N_range){
for (MIO_time in MIO_Times){
for (str in Types){
  
Sigma = format(Sigma, nsmall=1)
Target_seq = as.character(seq(1,P))
      
read_path=paste("R_Files/", str, "_Positions/",
                toString(P), "_", 
                toString(T), "_", 
                toString(Scenario_num), "_",
                toString(Sim_num), "_",
                toString(Sigma), "_", 
                toString(N), "_",
                toString(MIO_time), ".csv", sep="")

Positions = read.csv(read_path, header = TRUE)

read_path=paste("R_Files/", str, "_Associations/", 
                toString(P),"_", 
                toString(T), "_", 
                toString(Scenario_num), "_", 
                toString(Sim_num), "_",
                toString(Sigma), "_", 
                toString(N), "_",
                toString(MIO_time), ".csv", sep="")

Detections = read.csv(read_path, header = TRUE)    

Positions$Target_ID  = factor(Positions$Target_ID, levels=Target_seq)
Detections$Target_ID = factor(Detections$Target_ID, levels=Target_seq)

Title_str = paste(str,"Associations and Trajectories")
      
plot = ggplot(data=Detections,
              aes(x=Time,
                  y=Position,
                  color=Target_ID)) +
  geom_point(size=5) +
  geom_line(data=Positions, 
            aes(x=Time,
                y=Position,
                color=Target_ID)) +
  ggtitle(Title_str)+
  theme(axis.text=element_text(size=16),
        axis.title=element_text(size=18,face="bold"),
        plot.title=element_text(size = rel(2)),
        legend.text=element_text(size=14),
        legend.title=element_text(size=14),
        strip.text.x=element_text(size = 14),
        strip.text.y=element_text(size = 14)) +
  xlab("Time") +
  ylab("Position")
      
Save_path = paste("Scenario_Plots/", str, "/", 
                  toString(P),"_",
                  toString(T),"_", 
                  toString(Scenario_num),"_", 
                  toString(Sim_num), "_", 
                  toString(Sigma),"_", 
                  toString(N), "_",
                  toString(MIO_time), ".png",sep="")
      
png(file=Save_path,width=1000, height=700)
print(plot)
dev.off()
}}}}}}}}
