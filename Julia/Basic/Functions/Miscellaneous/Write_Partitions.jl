function write_partitions(Partitions::Vector{Vector{Float64}}, 
						              Write_path::ASCIIString, 
						              P::Int64, T::Int64)

  open(Write_path,"w") do fp
    for t in 1:T
      for p in 1:(P-1)
        print(fp, Partitions[t][p], ",")
      end
        print(fp, Partitions[t][P])
        print(fp, "\n")
    end
  end
end
