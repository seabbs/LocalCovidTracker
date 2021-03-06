### Code by Robert Hinch and Michelle Kendall for plotting cases by age

dir           = "data/"

load(glue("{dir}/CBA_data.RData"))

#tmp <- CBA_data %>% filter(areaType == "utla")
# CBA.utlas.alphabetical <- sort(unique(tmp$areaName))
# save(CBA.utlas.alphabetical, file="data/CBA.utlas.alphabetical.RData")
# tmp <- CBA_data %>% filter(areaType == "ltla")
# CBA.ltlas.alphabetical <- sort(unique(tmp$areaName))
# save(CBA.ltlas.alphabetical, file="data/CBA.ltlas.alphabetical.RData")

load("data/CBA.utlas.alphabetical.RData")
load("data/CBA.ltlas.alphabetical.RData")

### England data

male_suffix_E   = "_malecases.csv"
female_suffix_E = "_femalecases.csv"

# get the all the available files
files_E = system( sprintf( "ls %s*%s", dir, male_suffix_E ), intern = TRUE)
dates_E = str_replace_all( str_replace_all( files_E, dir, "" ), male_suffix_E, "" )
dates_E = as.Date( dates_E )

# Use this if and when we re-automate updates
# see if different to last date stored
# last_date_file = "data/last_date_plotted"
# if( file.exists( last_date_file ) )
# {
#   load( last_date_file )
# } else
#   last_date = as.Date( "2000-01-01")
# 
# if( dates[ length( dates ) ] == last_date )
#   stop( "no new data" )
# last_date = dates[ length( dates ) ] 

# load the data
t_E = list()
for( ddx in 1:length( dates_E ) )
{
  t_E_m = fread( file = sprintf( "%s%s%s", dir, dates_E[ ddx ], male_suffix_E ) )
  t_E_f = fread( file = sprintf( "%s%s%s", dir, dates_E[ ddx ], female_suffix_E ) )
  t_E[[ddx ]] = t_E_m[ t_E_f[ ,.(age, cases_f = value)], on = "age"][ ,.( age, cases = value + cases_f, date = ddx )] 
}
t_E = rbindlist( t_E, use.names = TRUE)

# calculate the daily increase and reformatting
t_E = t_E[ , .(age, date, new = cases)][ t_E[,.( age, old = cases, date = date + 1 )], on = c( "age", "date" ) ]
t_E = t_E[ !is.na( new ), .( age, date, cases = new - old )]
t_E[, age_num := as.double( stri_replace_all_fixed( stri_split_fixed( age, "_", simplify = TRUE)[,1], "+","" ) )]
t_E = t_E[ order( age_num)]
t_E$age = factor( t_E$age, levels= t_E[ , unique( age)])
t_E[ , age_format := str_replace_all( age, "_to_", "-")]
t_E = t_E[ t_E[ , .(cases_tot = sum( cases)), by = "date"], on = "date"]
t_E[ , cases_norm := cases / cases_tot]
t_E[ , date := dates_E[ date ]]


# ONS projection of population by age bracket for 2020 from https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationprojections/datasets/tableh24highpopulationvariantenglandpopulationinagegroups

pop_by_age_E <- c(3269,
                  3546,
                  3442,
                  3115,
                  3468,
                  3792,
                  3845,
                  3758,
                  3487,
                  3649,
                  3881,
                  3768,
                  3206,
                  2794,
                  2821,
                  2019,
                  1461,
                  895,
                  402 + 111 + 13)
                
prop_by_age_E <- cbind.data.frame(
  "age_format" = unique(t_E$age_format),
  "pc" = pop_by_age_E / sum(pop_by_age_E) * 100
)

mean_age_E    = t_E[ , .( mean_age = sum( ( age_num + 2.5 ) * cases ) / sum(cases) ), by = "date"] 
mean_age_E$date_colour <- as.factor(1:(length(dates_E) - 1))



### Wales data

male_suffix_W   = "_malecases_W.csv"
female_suffix_W = "_femalecases_W.csv"

# get the all the available files
files_W = system( sprintf( "ls %s*%s", dir, male_suffix_W ), intern = TRUE)
dates_W = str_replace_all( str_replace_all( files_W, dir, "" ), male_suffix_W, "" )
dates_W = as.Date( dates_W )

# load the data
t_W = list()
for( ddx in 1:length( dates_W ) )
{
  t_W_m = fread( file = sprintf( "%s%s%s", dir, dates_W[ ddx ], male_suffix_W ) )
  t_W_f = fread( file = sprintf( "%s%s%s", dir, dates_W[ ddx ], female_suffix_W ) )
  t_W[[ddx ]] = t_W_m[ t_W_f[ ,.(age, cases_f = value)], on = "age"][ ,.( age, cases = value + cases_f, date = ddx )] 
}
t_W = rbindlist( t_W, use.names = TRUE)

# calculate the daily increase and reformatting
t_W = t_W[ , .(age, date, new = cases)][ t_W[,.( age, old = cases, date = date + 1 )], on = c( "age", "date" ) ]
t_W = t_W[ !is.na( new ), .( age, date, cases = new - old )]
t_W[, age_num := as.double( stri_replace_all_fixed( stri_split_fixed( age, "_", simplify = TRUE)[,1], "+","" ) )]
t_W = t_W[ order( age_num)]
t_W$age = factor( t_W$age, levels= t_W[ , unique( age)])
t_W[ , age_format := str_replace_all( age, "_to_", "-")]
t_W = t_W[ t_W[ , .(cases_tot = sum( cases)), by = "date"], on = "date"]
t_W[ , cases_norm := cases / cases_tot]
t_W[ , date := dates_W[ date ]]


# ONS projection of population by age bracket for 2020 from https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationprojections/datasets/tableh24highpopulationvariantenglandpopulationinagegroups

pop_by_age_W <- c(164,
                  183,
                  185,
                  172,
                  203,
                  206,
                  196,
                  186,
                  173,
                  193,
                  217,
                  222,
                  197,
                  180,
                  182,
                  131,
                  91,
                  55,
                  24 + 6 + 1)

prop_by_age_W <- cbind.data.frame(
  "age_format" = unique(t_W$age_format),
  "pc" = pop_by_age_W / sum(pop_by_age_W) * 100
)

mean_age_W    = t_W[ , .( mean_age = sum( ( age_num + 2.5 ) * cases ) / sum(cases) ), by = "date"] 
mean_age_W$date_colour <- as.factor(1:(length(dates_W) - 1))


### England plotting

palette_E <- viridis( length( dates_E ), direction = -1 )

# plot
CBA_plot_E = plot_ly( type = "bar" ) 
CBA_plot_E = CBA_plot_E %>% add_trace(
  data = prop_by_age_E,
  x = ~age_format,
  y = ~pc,
  type = "scatter",  mode = "markers" , showlegend = FALSE,
  hovertemplate = paste(
    '%{y:.1f}% of the population<br>',
    'are %{x} year-olds.<br><extra></extra>'),
  size = 2
)
CBA_plot_E = CBA_plot_E %>% layout( 
  barmode = "group",
  xaxis = list(
    title = "Age group",
    titlefont = f1,
    showticklabels = TRUE,
    tickfont = f1
  ),
  yaxis   = list(
    title = "Percentage of daily cases",
    titlefont = f1,
    showticklabels = TRUE,
    tickfont = f1
  )
)


mean_age_plot_E = plot_ly( mean_age_E, x = ~date, y = ~mean_age, type = "scatter",  mode = "markers" ,
                 color = ~date_colour, colors = palette_E,
                 hovertemplate = paste(
                   '<i>%{x|%d %B}</i><br>',
                   'Mean age = %{y:.1f}<extra></extra>'),
                 showlegend = FALSE,
                 size = 3) %>%
  # add_segments(type="line",
  #              x = as.Date("2020-05-18"), xend = as.Date("2020-05-18"),
  #              y = 0, yend = 70,
  #              line=list(dash='dash',
  #                        color="lightgrey"),
  #              hovertemplate = paste('<extra></extra>')) %>%
  # add_annotations(
  #   x= "2020-05-18",
  #   y= 50,
  #   xref = "x",
  #   yref = "y",
  #   text = "
  #                Launch of 
  #                widespread testing
  #                programme",
  #   showarrow = F
  # )
  layout(showlegend = FALSE,
  xaxis = list(
    title = "Date",
    titlefont = f1,
    showticklabels = TRUE,
    tickfont = f1,
    range=c(min(dates_E), max(dates_E) + 2)
  ),
  yaxis = list(
    title = "Mean age of cases",
    titlefont = f1,
    showticklabels = TRUE,
    tickfont = f1,
    range=c(floor(min(mean_age_W$mean_age, mean_age_E$mean_age)) - 1, ceiling(max(mean_age_W$mean_age, mean_age_E$mean_age)) + 1)
  )
) 

# plot absolute numbers of cases for each age
abs_age_palette <- viridis(19, option="plasma", direction=-1)

# age format is plotting in an unhelpful order, with "5-9" following "45-40"
t_E$age_format <- factor(t_E$age_format, levels=sort(unique(t_E$age_format))[c(1,10,2:9,11:19)])

CBA_absolute_E <- plot_ly(t_E, x= ~date, y= ~cases, color= ~age_format, colors=abs_age_palette) %>%
  add_lines(text = t_E$age_format,
            hovertemplate = paste(
              'On %{x|%b %d} there were %{y} cases<br>among %{text} year-olds.<extra></extra>')) %>% 
  layout(
    xaxis = list(
      title = "Date",
      titlefont = f1,
      showticklabels = TRUE,
      tickfont = f1
    ),
    yaxis   = list(
      title = "Daily cases",
      titlefont = f1,
      showticklabels = TRUE,
      tickfont = f1
    )
  ) %>%
  add_segments(type="line",
               x = "2020-05-18", xend = "2020-05-18", 
               y = 0, yend = 3000,
               line=list(dash='dash',
                         color="lightgrey"),
               hovertemplate = paste('<extra></extra>'),
               showlegend = FALSE) %>%
  add_annotations(
    x= "2020-05-13",
    y= 1000,
    xref = "x",
    yref = "y",
    text = "
                 Launch of 
                 widespread testing
                 programme",
    showarrow = F
  )





### Wales plotting

palette_W <- viridis( length( dates_W ), direction = -1 )

# plot
CBA_plot_W = plot_ly( type = "bar" ) 
CBA_plot_W = CBA_plot_W %>% add_trace(
  data = prop_by_age_W,
  x = ~age_format,
  y = ~pc,
  type = "scatter",  mode = "markers" , showlegend = FALSE,
  hovertemplate = paste(
    '%{y:.1f}% of the population<br>',
    'are %{x} year-olds.<br><extra></extra>'),
  size = 2
)
for( ddx in 2:length( dates_W )) {
  CBA_plot_W = CBA_plot_W %>% add_bars( 
    data   = t_W[ date == dates_W[ ddx ] ],
    x      = ~age_format,
    y      = ~cases_norm*100, 
    text   = format( dates_W[ ddx ], "%d %B" ),
    name   = format( dates_W[ ddx ], "%d %B" ),
    marker = list( color = palette_W[[ddx]] ),
    hovertemplate = paste(
      '%{y:.1f}% of the cases<br>',
      'reported on %{text} <br>',
      'were among %{x} year-olds.<br><extra></extra>')
  )
}
CBA_plot_W = CBA_plot_W %>% layout( 
  barmode = "group",
  xaxis = list(
    title = "Age group",
    titlefont = f1,
    showticklabels = TRUE,
    tickfont = f1
  ),
  yaxis   = list(
    title = "Percentage of daily cases",
    titlefont = f1,
    showticklabels = TRUE,
    tickfont = f1
  )
)


mean_age_plot_W = plot_ly( mean_age_W, x = ~date, y = ~mean_age, type = "scatter",  mode = "markers" ,
                           color = ~date_colour, colors = palette_W,
                           hovertemplate = paste(
                             '<i>%{x|%d %B}</i><br>',
                             'Mean age = %{y:.1f}<extra></extra>'),
                           showlegend = FALSE,
                           size = 3)
mean_age_plot_W = mean_age_plot_W %>%
  layout(showlegend = FALSE,
         xaxis = list(
           title = "Date",
           titlefont = f1,
           showticklabels = TRUE,
           tickfont = f1,
           range=c(min(dates_W), max(dates_W) + 1)
         ),
         yaxis = list(
           title = "Mean age of cases",
           titlefont = f1,
           showticklabels = TRUE,
           tickfont = f1,
           range=c(floor(min(mean_age_W$mean_age)) - 1, ceiling(max(mean_age_W$mean_age)) + 1)
         )
  )

# age format is plotting in an unhelpful order, with "5-9" following "45-40"
t_W$age_format <- factor(t_W$age_format, levels=sort(unique(t_W$age_format))[c(1,10,2:9,11:19)])

CBA_absolute_W <- plot_ly(t_W, x= ~date, y= ~cases, color= ~age_format, colors=abs_age_palette) %>%
  add_lines(text = t_W$age_format,
            hovertemplate = paste(
              'On %{x|%b %d} there were %{y} cases<br>among %{text} year-olds.<extra></extra>')) %>% 
  layout(
    xaxis = list(
      title = "Date",
      titlefont = f1,
      showticklabels = TRUE,
      tickfont = f1
    ),
    yaxis   = list(
      title = "Daily cases",
      titlefont = f1,
      showticklabels = TRUE,
      tickfont = f1
    )
  )
               



last.date.of.ages.data <- format( max(dates_E,dates_W),  "%d %B %Y")
