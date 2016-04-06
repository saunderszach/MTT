function write_partitions(Partitions::Vector{Vector{Float64}}, 
						              Write_path::ASCIIString, 
						              T::Int64)

  Num_detections = zeros(Int64, T)

  for t = 1:T
    Num_detections[t] = length(Partitions[t])
  end

  open(Write_path,"w") do fp
    for t in 1:T
      if Num_detections[t] == 0
      
        println(fp, "NULL")
      
      elseif Num_detections[t] == 1

        print(fp, Partitions[t][1])
        print(fp, "\n")

      else
      
        for i in 1:(Num_detections[t]-1)
          print(fp, Partitions[t][i], ",")
        end
      
        print(fp, Partitions[t][Num_detections[t]])
        print(fp, "\n")
      
      end
    end
  end
end
