
### DEFINE PARAMETERS ###
const σ_1               = 0.1               # 1st noise parameter value
const σ_2               = 0.5               # 2nd noise parameter value
const σ_3               = 1.0               # 3rd noise parameter value
const σ_4               = 2.0               # 4th noise parameter value

const γ_min             = 0.80              # Minimum missed detection probability
const γ_step            = 0.05              # Missed detection probability step size
const γ_max             = 0.95              # Maximum missed detection probability

const λ_1               = 0.1               # 1st false alarm rate
const λ_2               = 0.5               # 2nd false alarm rate
const λ_3               = 1.0               # 3rd false alarm rate
const λ_4               = 2.0               # 4th false alarm rate

### CONSTRUCT RANGES ###
σ_range           = Float64[σ_1, σ_2, σ_3, σ_4]               # Range of scenaro noise
γ_range           = collect(γ_min:γ_step:γ_max)               # Range of missed detection probabilities
λ_range           = Float64[λ_1, λ_2, λ_3, λ_4]               # Range of false alarm rates

### DEFINE θ PENALTIES ###
θ_matrix = Array(Float64, 4, 4, 4)

θ_matrix[1,:,:] = [1.7 1.1 0.9 0.5;
                   1.7 1.1 0.9 0.5;
                   1.7 1.1 0.9 0.5;
                   1.7 1.1 0.9 0.5]

θ_matrix[2,:,:] = [2.6 1.9 1.2 0.9;
                   2.6 1.9 1.2 0.9;
                   2.6 1.9 1.2 0.9;
                   2.6 1.9 1.2 0.9]

θ_matrix[3,:,:] = [3.1 2.3 1.6 0.9;
                   3.1 2.3 1.6 0.9;
                   3.1 2.3 1.6 0.9;
                   3.1 2.3 1.6 0.9]

θ_matrix[4,:,:] = [3.5 2.5 1.8 1.0;
                   3.5 2.5 1.8 1.0;
                   3.5 2.5 1.8 1.0;
                   3.5 2.5 1.8 1.0]

### DEFINE ϕ PENALTIES ###
ϕ_matrix = Array(Float64, 4, 4, 4)

ϕ_matrix[1,:,:] = [0.1 0.1 0.1 0.1;
                   0.1 0.2 0.2 0.2;
                   0.1 0.2 0.2 0.2;
                   0.2 0.2 0.3 0.3]

ϕ_matrix[2,:,:] = [0.1 0.2 0.2 0.2;
                   0.2 0.25 0.25 0.25;
                   0.3 0.3 0.4 0.5;
                   0.5 0.5 0.7 0.7]

ϕ_matrix[3,:,:] = [0.3 0.3 0.3 0.3;
                   0.4 0.4 0.4 0.4;
                   0.5 0.5 0.5 0.6;
                   0.8 0.8 0.8 0.9]

ϕ_matrix[4,:,:] = [0.4 0.4 0.4 0.4;
                   0.4 0.4 0.4 0.5;
                   0.5 0.6 0.6 0.6;
                   0.7 0.8 0.8 1.0]

open("Penalties.csv","w") do fp
      println(fp, "Sigma,Gamma,Lambda,Theta,Phi")
end

for k in 1:4
      for i in 1:4
            for j in 1:4 
                   open("Penalties.csv","a") do fp
                       println(fp, string(σ_range[k]), ",",
                                   string(round(1-γ_range[i],2)), ",",
                                   string(λ_range[j]), ",",
                                   string(θ_matrix[k,i,j]), ",",
                                   string(ϕ_matrix[k,i,j]))
                  end

            end
      end 
end 





# open("Penalties.txt","w") do fp
#       println(fp, string(string(\), "begin{table}[ht]"))
#       println(fp, string(string(\), "centering"))
#       println(fp, string(string(\), "begin{tabular}{c|c|c|c|c}"))
#       println(fp, string(string(\), "hline"))
#       println(fp, string("\$", string(\), "sigma\$ & \$", string(\),  "gamma\$ & \$", string(\), "lambda\$ & \$", string(\), "theta_{0}\$ & \$", string(\), "phi_{0}\$", string(\),string(\)))
#       println(fp, string(string(\), "hline"))
# end

# for k in 1:4
#       for i in 1:4
#             for j in 1:4
#                   open("Penalties.txt","a") do fp
#                         println(fp, 
#                               string(string(σ_range[k]), " & ",
#                                      string(round(1-γ_range[i],2)), " & ",
#                                      string(λ_range[j]), " & ",
#                                      string(θ_matrix[k,i,j]), " & ",
#                                      string(ϕ_matrix[k,i,j]), " ",
#                                      string(\), string(\))) 
#                   end
#             end 
#       end
# end

# open("Penalties.txt","a") do fp
#       println(fp, string(string(\), "hline"))
#       println(fp, string(string(\), "end{tabular}"))
#       println(fp, string(string(\), "caption{Experiment 2 penalty values.}"))
#       println(fp, string(string(\), "label{tab:Penalties}"))
#       println(fp, string(string(\), "end{table}"))
# end