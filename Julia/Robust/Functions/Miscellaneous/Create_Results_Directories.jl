function create_directories(Path_stem::ASCIIString,
                            P_range::Array{Int64,1},
                            T_range::Array{Int64,1})

  mypath = string(Path_stem, "Results")
  isdir(mypath) || mkdir(mypath)

  mypath = string(Path_stem, "Results/Files")
  isdir(mypath) || mkdir(mypath)

  mypath = string(Path_stem, "Results/Plots")
  isdir(mypath) || mkdir(mypath)
  

  mypath = string(Path_stem, "R_Files")
  isdir(mypath) || mkdir(mypath)

  mypath = string(Path_stem, "R_Files/True_Positions")
  isdir(mypath) || mkdir(mypath)

  mypath = string(Path_stem, "R_Files/Ideal_Positions")
  isdir(mypath) || mkdir(mypath)

  mypath = string(Path_stem, "R_Files/Heuristic_Positions")
  isdir(mypath) || mkdir(mypath)

  mypath = string(Path_stem, "R_Files/MIO_Positions")
  isdir(mypath) || mkdir(mypath)

  mypath = string(Path_stem, "R_Files/Ideal_Associations")
  isdir(mypath) || mkdir(mypath)

  mypath = string(Path_stem, "R_Files/Heuristic_Associations")
  isdir(mypath) || mkdir(mypath)

  mypath = string(Path_stem, "R_Files/MIO_Associations")
  isdir(mypath) || mkdir(mypath)

  for P in P_range

    mypath = string(Path_stem, "R_Files/True_Positions/", string(P))
    isdir(mypath) || mkdir(mypath)

    mypath = string(Path_stem, "R_Files/Ideal_Positions/", string(P))
    isdir(mypath) || mkdir(mypath)

    mypath = string(Path_stem, "R_Files/Heuristic_Positions/", string(P))
    isdir(mypath) || mkdir(mypath)

    mypath = string(Path_stem, "R_Files/MIO_Positions/", string(P))
    isdir(mypath) || mkdir(mypath)

    mypath = string(Path_stem, "R_Files/Ideal_Associations/", string(P))
    isdir(mypath) || mkdir(mypath)

    mypath = string(Path_stem, "R_Files/Heuristic_Associations/", string(P))
    isdir(mypath) || mkdir(mypath)

    mypath = string(Path_stem, "R_Files/MIO_Associations/", string(P))
    isdir(mypath) || mkdir(mypath)

    for T in T_range

      mypath = string(Path_stem, "R_Files/True_Positions/", string(P), string(/), string(T))
      isdir(mypath) || mkdir(mypath)

      mypath = string(Path_stem, "R_Files/Ideal_Positions/", string(P), string(/), string(T))
      isdir(mypath) || mkdir(mypath)

      mypath = string(Path_stem, "R_Files/Heuristic_Positions/", string(P), string(/), string(T))
      isdir(mypath) || mkdir(mypath)

      mypath = string(Path_stem, "R_Files/MIO_Positions/", string(P), string(/), string(T))
      isdir(mypath) || mkdir(mypath)

      mypath = string(Path_stem, "R_Files/Ideal_Associations/", string(P), string(/), string(T))
      isdir(mypath) || mkdir(mypath)

      mypath = string(Path_stem, "R_Files/Heuristic_Associations/", string(P), string(/), string(T))
      isdir(mypath) || mkdir(mypath)

      mypath = string(Path_stem, "R_Files/MIO_Associations/", string(P), string(/), string(T))
      isdir(mypath) || mkdir(mypath)

    end # T_range
  end # P_range

end #create_directories
