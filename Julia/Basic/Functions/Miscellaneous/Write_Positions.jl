function write_positions(Positions::Vector{Vector{Float64}},
                         Assignments::Array{Int64,1},
                         Write_path::ASCIIString,
                         P::Int64, T::Int64)

open(Write_path,"w") do fp
    println(fp, "Time,Position,Target_ID")
end

  open(Write_path,"a") do fp
    for p in 1:P

      index = findin(Assignments,p)[1]

      for t in 1:T
        	println(fp, t, ",", Positions[t][index], ",", index)
      end
	   
     end
  end

end #write_R_file.jl