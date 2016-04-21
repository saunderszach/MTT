function read_partitions(fileName::ASCIIString)

	f = open(fileName)
		Partitions = [[parse(Float64,e) for e in split(ln[1:end-1], ",")] for ln in readlines(f)]
	close(f)

  #Partitions = Base.mapfoldl(line -> map(x->parse(Float64,x), split(chomp(line), ",")), push!, Vector{Float64}[], open(Read_path) |> eachline)

  return Partitions
  
end

