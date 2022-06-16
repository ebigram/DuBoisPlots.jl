function Plate10Recipe(data::DataFrame,main_cat::Symbol, sub_cat::Symbol,
  main_labs::Array{String,1},sub_labs::Array{String,1}, leg_labs::Array{String,1}, title ="")

  # data = CSV.read(joinpath(@__DIR__,"../../data/Plate10.csv"),DataFrame)
  df = stack(data)

  # Creating array of dataframes with like main categories
  grp = [df[df[:,main_cat] .== unique(df[:,main_cat])[i],:] for i in 1:size(unique(df[:,main_cat]))[1]]

  fig = Figure(resolution = (792,1008)) # Create figure element
  g_top = fig[1,2:3] = GridLayout()
  g_leg = fig[2,3]
  g_plot = fig[3,3] = GridLayout()
  g_left = fig[3,2] = GridLayout()
  g_bot = fig[4,1:4] = GridLayout()
  g_left_margin = fig[1:4,1] = GridLayout()
  g_right_margin = fig[1:4,4] = GridLayout()

  title = uppercase(title)
  Label(g_top[1,1], title, textsize = 30, color = :black)

  # Creating main categories' labels and placement
  for i in 1:size(unique(df[:,main_cat]))[1]
    Label(g_left[(3i-2):(3i-1),1],main_labs[i], textsize = 17)
  end

  axtitle = Axis(g_top[1,1])
  hidespines!(axtitle)
  hidexdecorations!(axtitle)
  hideydecorations!(axtitle)

  # Creating sub-categories' axes with labels
  allaxes = [[Axis(g_plot[(3i-2):(3i-1),1:3],
  yticks = ([length(sub_labs):-1:1;],sub_labs))] for i in 1:size(unique(df[:,main_cat]))[1]]

  # Creating 2 dummy arrays with indicators for each of the two subcategories to be parsed in stacked plot
  c = zeros(0)
  d = zeros(0)

  for i in grp[1].variable # This means I have to have an assertion making the order for variable, population the same among all elements of grp
    append!(c, findall(x->x==i, unique(grp[1].variable)))
  end

  for i in grp[1][:,sub_cat]
    append!(d, findall(x->x == i, unique(grp[1][:,sub_cat])))
  end

  c = Int.(c)
  d = Int.(d)

  # Think about how to make the possible number of colors longer
  colors = [colorant"#DC143c",colorant"#FFD700",colorant"#00AA00"]


  npop = size(unique(d))[1]
  for igrp in 1:length(grp)[1]
    k=grp[igrp]
    nage = size(unique(k[:,:variable]))[1]
    xpos=fill(0.0,(nage,npop))
    for i = 1:nage
      for j = 1:npop
    # i should be 3, the number of categories in Age.
    # j should be 2, the number of categories in Population.
    # we want to produce a 3x2 matrix where each column corresponds with one Population category, each row with one Age category. 9
        xpos[i,j] = k[d.==j,:value][i]/2 # "New value"
        if (i >= 2) == true
          xpos[i,j] +=  sum(k[d.==j,:value][1:i-1]) # Sum of previous value
        end
      end
    end
    xpos = reshape(xpos,nage*npop)

    # println(i,d,grp[igrp][1,:value])
    barplot!(allaxes[igrp][1], d, grp[igrp][:,:value],
      colormap = colors,
      stack = c,
      color = c,
      direction = :x,
      width = 0.5)

    text!(allaxes[igrp][1],
      ["$i%" for i in [grp[igrp][d.==1,:value] ; grp[igrp][d.==2,:value]]],
      position= Point.([xpos[i] for i =1:nage*npop], sort(d)),
      textsize = 15,
      align=(:center,:center))
  end


  for i in allaxes
    hidespines!(i[1])
    hidexdecorations!(i[1])
    hideydecorations!(i[1], ticklabels = false)
  end
  fig

  # Legend
  leg_colors = [colorant"#DC143C",colorant"#00AA00",colorant"#FFD700"]
  elements = [MarkerElement(marker = :circle, markersize = 25, color = leg_colors[i]) for i in 1:length(main_labs)]

  Legend(g_leg, elements, leg_labs, nbanks = 2, framevisible = false, rowgap = 15, colgap = 100)

  rowsize!(fig.layout, 1, Relative(0.1))
  rowsize!(fig.layout, 2, Relative(0.05))
  rowsize!(fig.layout, 4, Relative(0.1))
  colsize!(fig.layout, 1, Relative(0.05))
  colsize!(fig.layout, 3, Relative(0.8))

  fig

end
