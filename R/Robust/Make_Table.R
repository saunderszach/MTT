library(ggplot2)
library(dplyr)
library(tidyr)
library(xtable)

Raw_Data = read.csv('Documents/Academic/Research/Git/Multi-Target-Tracking/Julia/Robust/LaTeX_scripts/Penalties.csv', header=TRUE)

Table_1 = Raw_Data %>% group_by(Sigma,Lambda) %>% summarize(Avg_Theta = mean(Theta)) %>% spread(Sigma,Avg_Theta)

xtable(Table_1)

Table_2 = Raw_Data %>% group_by(Sigma,Lambda,Gamma) %>% summarize(Avg_Phi = mean(Phi)) %>% spread(Sigma,Avg_Phi)

xtable(Table_2)
