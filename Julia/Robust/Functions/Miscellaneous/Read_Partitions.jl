function read_partitions(Read_path::ASCIIString, T::Int64)

  Partitions = Base.mapfoldl(line -> map(float64, split(chomp(line), ",")), push!, Vector{Float64}[], open(Read_path) |> eachline)

  return Partitions
  
end

