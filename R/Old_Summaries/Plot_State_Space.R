library(ggplot2)
library(dplyr)
library(tidyr)

setwd("~/Desktop/Results/Basic/")

Num_scenarios = 20

State_space=read.csv("Files/State_Space.csv",header=TRUE)
State_space$P <- factor(State_space$P)
State_space$T <- factor(State_space$T)
State_space$Sigma <- factor(State_space$Sigma)

Data=State_space%>%filter(Rho_Type == "Proximity")
Data$Rho_Type = NULL

plot = ggplot(data=Data, 
              aes(x=Sigma,
                  y=Rho,
                  color=Scenario_Type)) +
  geom_boxplot() +
  facet_grid(P~T, labeller=label_both) +
  ggtitle(paste("Sigma vs Rho for",toString(Num_scenarios),"Scenarios by Scenario Type")) +
  theme(axis.text=element_text(size=16),
        axis.title=element_text(size=18,face="bold"),
        plot.title=element_text(size=rel(2)),
        legend.text=element_text(size=14),
        legend.title=element_text(size=14),
        strip.text.x=element_text(size=14),
        strip.text.y=element_text(size=14)) +
  xlab("Sigma") +
  ylab("Rho") + guides(color=guide_legend(title='Scenario Type')) 
Save_str = paste("Plots/State_Space/State_Space.png", sep="")
png(file=Save_str,width=1000, height=700)
print(plot)
dev.off()

