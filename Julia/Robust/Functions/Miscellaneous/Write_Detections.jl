function write_detections(Detections::Vector{Vector{Float64}}, 
						              Write_path::ASCIIString,
                          T::Int64)

  Num_detections = zeros(Int64, T)

  for t = 1:T
    Num_detections[t] = length(Detections[t])
  end

  open(Write_path,"w") do fp
    for t in 1:T
      if Num_detections[t] == 0
      
        println(fp, "NULL")
      
      elseif Num_detections[t] == 1

        print(fp, Detections[t][1])
        print(fp, "\n")

      else
      
        for i in 1:(Num_detections[t]-1)
          print(fp, Detections[t][i], ",")
        end
      
        print(fp, Detections[t][Num_detections[t]])
        print(fp, "\n")
      
      end
    end
  end
end
