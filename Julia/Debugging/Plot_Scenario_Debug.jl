using DataFrames

### Fill new vectors for use in a data frame
Time = Int64[]
Position = Float64[]
Target_ID = Char[]

for t=1:T
    for i=1:P
      push!(Time,(t-1))
      push!(Position, True_Position[t][i])
      push!(Target_ID,convert(Char,i))
    end
end

### Construct the data frame
df = DataFrame()
df[:Time]     = Time
df[:Position] = Position
df[:Target_ID]= Target_ID


colors = shuffle(linspace(LCHuv(70, 70, 0), LCHuv(70, 70, 315), 8))


### Plot the scenario along with scenario parameters
title_string = string("True Trajectories of Sumulation # 1")
p = plot(df,  layer(x="Time", y="Position", color="Target_ID",  Geom.line),
           Scale.y_continuous(minvalue=-6, maxvalue=6),
           Scale.color_discrete_manual(colors...),
           Theme(line_width=5px, key_position = :none),
           Guide.colorkey("Target "),
           Guide.xlabel("Time"), Guide.ylabel("Position"), Guide.title(title_string))
Save_String = string(Path_Stem, "Julia/Results/Scenario_Plots/Sim_", Sim_Num, ".pdf")
draw(PDF(Save_String, 16cm, 8cm), p)

