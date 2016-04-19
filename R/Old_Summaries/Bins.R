DataBloop=Data%>%filter(Rho_Type=="Average")
bins=c(0,1,3,1000)
for(i in 2:length(bins)) {
DataBloop[DataBloop$Rho<=bins[i] & DataBloop$Rho>bins[i-1],]$Rho=(bins[i]+bins[i-1])/2
}
DataBloop$Rho=factor(DataBloop$Rho)
Rho_Data = DataBloop %>% filter(Scenario_Type == "Crossing")#Parallel")
Rho_Data$Solution_Type = factor(Rho_Data$Solution_Type)

##########################################
###                                    ###
###  Delta vs Rho By Solution Type  ###
###                                    ###
##########################################

Rho_Data2 = Rho_Data %>% filter(Solution_Type!="MIO_3T_sec", N=="1000") %>% group_by(P,T,Rho,Solution_Type) %>% summarize(mean.value=mean(Delta),max.value=max(Delta),min.value=min(Delta))

ggplot(data = Rho_Data2,
                aes(x=Rho,
                    y=mean.value,
                    color=Solution_Type)) +
  geom_line(aes(group=Solution_Type)) +
  # geom_ribbon(data=Rho_Data2,
  #             aes(x=Rho,
  #                 ymin=min.value,
  #                 ymax=max.value,
  #                 fill=Solution_Type),
  #             alpha=.1) +
  facet_grid(P~T, labeller=label_both) +
  ggtitle("Mean Delta vs Average Rho by Solution Type") +
  theme(axis.text=element_text(size=16),
        axis.title=element_text(size=18,face="bold"),
        plot.title=element_text(size = rel(2)),
        legend.text=element_text(size=14),
        legend.title=element_text(size=14),
        strip.text.x=element_text(size = 14),
        strip.text.y=element_text(size = 14)) +
  xlab("Average Rho") +
  ylab("Delta") #+scale_x_log10()

