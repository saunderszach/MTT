function create_directories(Path_stem::ASCIIString,
                            P_range::Array{Int64,1},
                            T_range::Array{Int64,1},
                            Scenario_range::Array{Int64,1})

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

    ### Define variable parameters ###
    if P <= 6
      σ_range   = Float64[0.5, 1.0, 2.5, 5.0]     # Range of scenaro noise
    else
      σ_range   = Float64[1.0, 2.0, 5.0, 10.0]    # Range of scenaro noise
    end

      
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

      for Scenario_num in Scenario_range

        mypath = string(Path_stem, "Experiment/Data/", string(P), string(/), string(T), string(/), string(Scenario_num))
        isdir(mypath) || mkdir(mypath)

        mypath = string(Path_stem, "Experiment/Detections/", string(P), string(/), string(T), string(/), string(Scenario_num))
        isdir(mypath) || mkdir(mypath)

        mypath = string(Path_stem, "Experiment/MIP_Solutions/", string(P), string(/), string(T), string(/), string(Scenario_num))
        isdir(mypath) || mkdir(mypath)

        mypath = string(Path_stem, "Experiment/MIP_Summaries/", string(P), string(/), string(T), string(/), string(Scenario_num))
        isdir(mypath) || mkdir(mypath)

        mypath = string(Path_stem, "Experiment/Heuristic_Solutions/", string(P), string(/), string(T), string(/), string(Scenario_num))
        isdir(mypath) || mkdir(mypath)
          
        mypath = string(Path_stem, "Experiment/Simulation_Summaries/", string(P), string(/), string(T), string(/), string(Scenario_num))
        isdir(mypath) || mkdir(mypath)

        for σ in σ_range

          mypath = string(Path_stem, "Experiment/MIP_Solutions/", string(P), string(/), string(T), string(/), string(Scenario_num), string(/), string(σ))
          isdir(mypath) || mkdir(mypath)

          mypath = string(Path_stem, "Experiment/MIP_Summaries/", string(P), string(/), string(T), string(/), string(Scenario_num), string(/), string(σ))
          isdir(mypath) || mkdir(mypath)

          mypath = string(Path_stem, "Experiment/Heuristic_Solutions/", string(P), string(/), string(T), string(/), string(Scenario_num), string(/), string(σ))
          isdir(mypath) || mkdir(mypath)
            
          mypath = string(Path_stem, "Experiment/Simulation_Summaries/", string(P), string(/), string(T), string(/), string(Scenario_num), string(/), string(σ))
          isdir(mypath) || mkdir(mypath)

        end # σ_range 
      end # Scenario_range
    end # T_range
  end # P_range

end #create_directories
