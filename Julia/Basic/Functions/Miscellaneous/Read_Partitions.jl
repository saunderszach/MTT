function read_partitions(Read_path::ASCIIString, T::Int64)

  Data = readcsv(Read_path)

  Partitions = Array(Vector{Float64},T)

  for t = 1:T
    Partitions[t] = collect(Data[t,:])
  end

  return Partitions
end

