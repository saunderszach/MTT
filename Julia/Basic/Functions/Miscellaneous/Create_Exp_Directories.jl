function create_directories(Path_stem::ASCIIString,
                            P_range::Array{Int64,1},
                            T_range::Array{Int64,1})

  mypath = string(Path_stem, "Experiment/Data")
  isdir(mypath) || mkdir(mypath)

  mypath = string(Path_stem, "Experiment/Garbage")
  isdir(mypath) || mkdir(mypath)
  
  mypath = string(Path_stem, "Experiment/Detections")
  isdir(mypath) || mkdir(mypath)

  mypath = string(Path_stem, "Experiment/MIP_Solutions")
  isdir(mypath) || mkdir(mypath)

  mypath = string(Path_stem, "Experiment/MIP_Summaries")
  isdir(mypath) || mkdir(mypath)

  mypath = string(Path_stem, "Experiment/Heuristic_Solutions")
  isdir(mypath) || mkdir(mypath)
  
  mypath = string(Path_stem, "Experiment/Simulation_Summaries")
  isdir(mypath) || mkdir(mypath)

  for P in P_range
      
    mypath = string(Path_stem, "Experiment/Data/", string(P))
    isdir(mypath) || mkdir(mypath)

    mypath = string(Path_stem, "Experiment/Detections/", string(P))
    isdir(mypath) || mkdir(mypath)

    mypath = string(Path_stem, "Experiment/MIP_Solutions/", string(P))
    isdir(mypath) || mkdir(mypath)

    mypath = string(Path_stem, "Experiment/MIP_Summaries/", string(P))
    isdir(mypath) || mkdir(mypath)

    mypath = string(Path_stem, "Experiment/Heuristic_Solutions/", string(P))
    isdir(mypath) || mkdir(mypath)
      
    mypath = string(Path_stem, "Experiment/Simulation_Summaries/", string(P))
    isdir(mypath) || mkdir(mypath)

    for T in T_range

      mypath = string(Path_stem, "Experiment/Data/", string(P), string(/), string(T))
      isdir(mypath) || mkdir(mypath)

      mypath = string(Path_stem, "Experiment/Detections/", string(P), string(/), string(T))
      isdir(mypath) || mkdir(mypath)

      mypath = string(Path_stem, "Experiment/MIP_Solutions/", string(P), string(/), string(T))
      isdir(mypath) || mkdir(mypath)

      mypath = string(Path_stem, "Experiment/MIP_Summaries/", string(P), string(/), string(T))
      isdir(mypath) || mkdir(mypath)

      mypath = string(Path_stem, "Experiment/Heuristic_Solutions/", string(P), string(/), string(T))
      isdir(mypath) || mkdir(mypath)
        
      mypath = string(Path_stem, "Experiment/Simulation_Summaries/", string(P), string(/), string(T))
      isdir(mypath) || mkdir(mypath)

    end # T_range
  end # P_range

end #create_directories
