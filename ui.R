ui <- fluidPage( 
                 tags$style(type = "text/css",
                            "label { font-size: 16px; }"
                 ),
                 tags$head(includeHTML(("google-analytics.html"))), # google analytics token
                 tags$head(
                   tags$style(HTML(".leaflet-container { background: #FFFFFF; }"))
                 ), # make map backgrounds white
                 tags$head(tags$style(type='text/css', ".slider-animate-button { font-size: 26pt !important; }")), # make 'play' button nicer on slider
                 
  theme = shinytheme("yeti"), # change the theme here; use "themeSelector()" below for an easy way to pick
  #shinythemes::themeSelector(), # use this to dynamically select a theme
  
  titlePanel("Local Covid Tracker: epidemic surveillance and nowcasting for England and Wales"),
  
  tabsetPanel(
    id="tabs",
    
    tabPanel(
      "Map tracker",
      value="tab_map_tracker",
      
      h5("Select a date of interest or press 'play' (right) to watch the progression of the epidemic so far:"),
      
      sliderTextInput(
        inputId = "date.slider.maps", 
        label = NULL, 
        choices = format(seq(from=as.Date("2020-03-01"), to = last.date - R.trim - 1, by=1), "%d %b %y"),
        selected = format(last.date - R.trim - 1, "%d %b %y"),
        animate = animationOptions(
          interval = 1000,
          loop = FALSE,
          playButton = NULL,
          pauseButton = NULL
        ),
        grid = TRUE,
        width = "100%"
      ),
      
      div(style = "padding: 0px 0px; margin-top:-2em", 
          fluidRow(
            column(
              width=4,
              h3("Nowcast"),
              withSpinner(leafletOutput("NowcastMap", height="60vh"), type = 7)
            ),
            column(
              width=4,
              h3("New infections"),
              withSpinner(leafletOutput("InfectionsMap", height="60vh"), type = 7)
            ),
            column(
              width=4,
              h3("Instantaneous reproduction number R"),
              withSpinner(leafletOutput("RMap", height="60vh"), type = 7)
            )
          )                                       
      ),
      
      
      
      uiOutput("mapDate"),
      
      h5("For details of the data presented here please see the 'Daily tracker' tab."),
      
      
      # "last updated" info
      fluidRow(
        column(
          width=12,
          align="right",
          uiOutput("updatedInfoMaps")
        )
      )
      
    ), # end "map tracker" tabPanel
    
    
    tabPanel(
      "Daily tracker",
      value="tab_daily_tracker",
      
      # Sidebar with a slider inputs etc
      sidebarLayout(
        sidebarPanel(
          id = "sidePanel.daily",
          style = "overflow-y: auto; max-height: 100vh", 
          
          h3("Area to highlight"),

          selectInput("level",
                      h5("Select the area type of interest:"),
                      choices = c("Region of England"=1,
                                  "Upper tier local authority" = 2,
                                  "Lower tier local authority" = 3),
                      selected=2
                      ),

          conditionalPanel(
            condition = "input.level == 1",
            selectInput("region",
                        h5("Select a region to highlight:"),
                        choices = regions.alphabetical,
                        selected = random.region)
          ),

          conditionalPanel(
            condition = "input.level == 2",
            selectInput("utla",
                        h5("Select an upper tier local authority to highlight:"),
                        choices = utlas.alphabetical,
                        selected = random.utla)
          ),

          conditionalPanel(
            condition = "input.level == 3",
            selectInput("ltla",
                        h5("Select a lower tier local authority to highlight:"),
                        choices = ltlas.alphabetical,
                        selected = random.ltla)
          ),
          
          dateRangeInput("xrange", 
                         h5("Select date range:"),
                         start  = last.date-91,
                         end    = last.date,
                         min    = start.date,
                         max    = last.date,
                         format = "dd M yyyy"),

          helpText("Note that the plots are truncated 9-12 days before the last date of data available - see details below."),

          # checkboxInput(
          #   inputId = "ytype",
          #   label = "Use log scale for y axis?", 
          #   value = FALSE
          # ),
          
          hr(),

          h3("Details"),

          h4("Data"),
          
          HTML("<h5>We use the 'combined pillars' data from 
               <a href=\"https://coronavirus.data.gov.uk/about-data\" target=\"_blank\">PHE and NHSX</a> 
               which reports the number of new cases per day in local authorities of England and Wales
               according to the date the swab was administered. 
               From this data we estimate the number of new infections per day 
               (infections typically start roughly a week before the swab is administered, though this varies considerably)
               and from this we calculate the
               instantaneous reproduction number R.
               </h5>"),
          h5("We use an estimate for the typical time from the onset of symptoms to taking a swab test.
              To improve the accuracy we hope that local area data will soon be publicly available
             with more informative timing information such as the date of onset of symptoms or the date the test was requested."),

          h4("Interpretation"),
          
          h5("The last date which can be shown in each graph is 9-12 days earlier than the last date for which
             we have case numbers. 
             This is to account for reporting lags and the delay between an infection
             starting and a swab being taken. 
             However, the graphs are informed by the very latest data
             and do provide a meaningful assessment of the epidemic trajectory in each area."),
          
          HTML("<h5>The <i>nowcast</i> combines the estimated R and number of new infections each week
             to approximate the number of new infections expected shortly after the given date. 
             It assumes no change in interventions.</h5>"),
          HTML("<h5>The <i>instantaneous reproduction number R</i>
             is a measure of both the infectivity of the virus
             (expected to be roughly constant over this time frame)
             and the social network on which the virus is spreading.
             Decreasing our social contacts (social distancing, mask wearing, self-isolating)
             will reduce R; increasing social contacts will make it rise.
             When R is above 1 an epidemic will grow exponentially whereas when it is below 1 the epidemic will eventually die out.
             The further it is from 1, the faster these effects play out.</h5>"),
          
          h5("All estimates of the number of infections are based directly on case counts so we are estimating
             the number of infected individuals who will go on to get a positive test, not the true total number
             of infections, which will almost certainly be higher. 
             The results here are intended more as a means of comparing between areas than
             as an exact representation of the number of infections.
             Widespread community testing was launched on May 18th for everyone over the age of 5 with symptoms; 
             on May 28th the NHS Test and Trace programme was launched, with tests available for everyone with symptoms.
             Testing capacity has been gradually increasing since then.
             The rapid rise in infections shown in many areas in mid-late April is largely an artefact of 
             increased testing in May because we do not make adjustments to the case numbers for any such effects."),
          h5("Similarly, some of our estimates report R increasing through the first half of March.
             This is also an artefact of our method: we are not aware of any reasons to
             suppose that R was actually increasing during this time."),
          
          hr(),
          width=3
          ), # end sidebarPanel

        mainPanel(
          style = "overflow-y: auto; max-height: 100vh", 
          
          #HTML("<h3>Please note: technical issues with the <a href=\"https://coronavirus.data.gov.uk/cases\" target=\"_blank\">PHE and NHSX</a> database unfortunately mean that we have been
          #     unable to update this daily tracker since Monday 24th August. We hope the service will be restored soon.</h3>"),
          
          fluidRow(
            column(
              width=9,
              align="left",
              h3("Nowcast")
            ),
            column(
              width=3,
              align="right",
              downloadButton("downloadNowcast", "Download csv")
            )
          ),

          conditionalPanel(
            condition = "input.level == 2",
            withSpinner(plotlyOutput("UTLAProjectionPlot", height="60vh"), type=7)
          ),

          conditionalPanel(
            condition = "input.level == 1",
            withSpinner(plotlyOutput("regionProjectionPlot", height="60vh"), type=7)
          ),

          conditionalPanel(
            condition = "input.level == 3",
            withSpinner(plotlyOutput("LTLAProjectionPlot", height="60vh"), type=7)
          ),
          
          helpText("Please note that we base our estimates solely on positive test results -
                   we do not adjust for variations in test availability or testing backlogs. 
                   In particular, decreases in the last few days of the plots may be an artefact of
                   under-reporting and/or delayed reporting."),

          hr(),
          fluidRow(
            column(
              width=9,
              align="left",
              h3("New infections")
            ),
            column(
              width=3,
              align="right",
              downloadButton("downloadIncidence", "Download csv")
            )
          ),

          conditionalPanel(
            condition = "input.level == 2",
          withSpinner(plotlyOutput("UTLAIncidencePlot", height="60vh"), type=7)
          ),

          conditionalPanel(
            condition = "input.level == 1",
            withSpinner(plotlyOutput("regionIncidencePlot", height="60vh"), type=7)
          ),

          conditionalPanel(
            condition = "input.level == 3",
            withSpinner(plotlyOutput("LTLAIncidencePlot", height="60vh"), type=7)
          ),

          hr(),

          fluidRow(
            column(
              width=9,
              align="left",
              h3("Instantaneous reproduction number R")
            ),
            column(
              width=3,
              align="right",
              downloadButton("downloadR", "Download csv")
            )
          ),

          conditionalPanel(
            condition = "input.level == 2",
            withSpinner(plotlyOutput("UTLARPlot", height="60vh"), type=7),

            withSpinner(plotlyOutput("ROneUTLAPlot", height="60vh"), type=7)
          ),

          conditionalPanel(
            condition = "input.level == 1",
            withSpinner(plotlyOutput("regionRPlot", height="60vh"), type=7),

            withSpinner(plotlyOutput("ROneRegionPlot", height="60vh"), type=7)
          ),

          conditionalPanel(
            condition = "input.level == 3",
            withSpinner(plotlyOutput("LTLARPlot", height="60vh"), type=7),

            withSpinner(plotlyOutput("ROneLTLAPlot", height="60vh"), type=7)
          ),

          hr(),
          
          # "last updated" info
          fluidRow(
            column(
              width=12,
              align="right",
              uiOutput("updatedInfo")
            )
          ),

        width=9
        ) # end mainPanel
      ) # end sidebarLayout

      ), # end "daily tracker" tabPanel
    tabPanel(
      "Cases by age",
      value="tab_CBA",
      
      sidebarLayout(
        sidebarPanel(
          
          h3("Area to highlight"),
          
          selectInput("CBA_level",
                      h5("Select the area type of interest:"),
                      choices = c("Country (England or Wales)"=1,
                                  "Upper tier local authority (England only)" = 2,
                                  "Lower tier local authority (England only)" = 3),
                      selected=2
          ),
          
          conditionalPanel(
            condition = "input.CBA_level == 1",
            selectInput(
              "CBA_country",
              h5("Select a country:"),
              choices = c("England", "Wales"),
              selected = random.country
            )
          ),
          
          conditionalPanel(
            condition = "input.CBA_level == 2",
            selectInput("CBA_utla",
                        h5("Select an upper tier local authority to highlight:"),
                        choices = CBA.utlas.alphabetical,
                        selected = random.utla)
          ),
          
          conditionalPanel(
            condition = "input.CBA_level == 3",
            selectInput("CBA_ltla",
                        h5("Select a lower tier local authority to highlight:"),
                        choices = CBA.ltlas.alphabetical,
                        selected = random.ltla)
          ),
          
          conditionalPanel(
            condition = "input.CBA_level == 2 || input.CBA_level == 3",
            selectInput("CBA_age_breadth",
                        h5("Show broad or narrow age bands:"),
                        choices = c("Broad"="broad", "Narrow"="narrow"),
                        selected = "broad")
          ),
          
          
          conditionalPanel(
            condition = "input.CBA_level == 1 && input.CBA_country == 'England'",
            dateRangeInput("xrange_CBA", 
                           h5("Select date range:"),
                           start  = last.date-91,
                           end    = last.date,
                           min    = "2020-03-15",
                           max    = last.date,
                           format = "dd M yyyy")
          ),
          
          h3("Details"),
          
          HTML("<h5>We present a breakdown of the daily cases by age category, using all the publicly available data from <a href=\"https://coronavirus.data.gov.uk/about-data\" target=\"_blank\">PHE and NHSX</a>.</h5>"),
          
          HTML("<h5>For Wales, this is unfortunately only available at the national level: the total (cumulative) 
          number of new cases in each age category is published each day, and we have been
               logging this data since late September.</h5>"),
          
          HTML("<h5>For England, cases by age are now available for the whole epidemic and can be explored here at the national and local authority levels.</h5>"),
          
          conditionalPanel(
            condition = "input.CBA_level == 1",
            h4("Country-level plots:"),
            
            HTML("<h5>In the first plot we show the proportion of new cases reported which fall into each age category, each day. 
Click on dates in the legend (key) to show/hide results 
                for individual days.</h5>"),
            
            HTML("<h5>The second plot presents the mean age of cases reported that day.</h5>"),
            
            HTML("<h5>Finally, the third plot shows the absolute number of cases reported for each age each day.
               You can show and hide age categories by clicking on the legend; 
               double-clicking on an individual age category shows that age alone, making it easier to identify any trends.</h5>"),
            
            HTML("<h5>Note that, unlike other results on this site where cases are plotted by their swab date,
               the age data at the country level is presented by the date it was first publicly reported.
               If reporting delays differ across age groups it could bias the trends seen here.
               
               </h5>")
            
          ),
          
          conditionalPanel(
            condition = "input.CBA_level == 2 || input.CBA_level == 3",
            h4("Local authority plots:"),
            
            HTML("<h5>In the first plot we show the absolute number of cases for each age each day, by specimen date.
            Choose from 'broad' (0-59 and 60+) or 'narrow' (5-year) age bands from the drop-down menu on the left.
               You can show and hide age categories by clicking on the legend; 
               double-clicking on an individual age category shows that age alone, making it easier to identify any trends within the 'narrow' band plot.</h5>"),
            
            HTML("<h5>The second plot presents the 'rolling rate' of cases by age. 
            The full definitions are given <a href=\"https://coronavirus.data.gov.uk/about-data#methodologies\" target=\"_blank\">here</a>;
            in brief, 'rolling' gives a moving weekly average to smooth over day-to-day variation,
                 and 'rate' is the result per 100,000 population.</h5>")
            
          ),
          
        width=3),
        mainPanel(
          
          conditionalPanel(
            condition = "input.CBA_level == 1",
            
            fluidRow(
              column(
                width=9,
                align="left",
                uiOutput("CaseDistributionTitle")
              ),
              column(
                width=3,
                align="right",
                downloadButton("CBA_Dist_download", "Download csv")
              )
            ),
            
            withSpinner(plotlyOutput("casesByAgePlot", height="60vh"), type=7),
            
            conditionalPanel(
              condition = "input.CBA_level == 1 && input.CBA_country == 'England'",
              helpText("We note that since late October the data for England has contained a surge of cases which
                     consistently moves to the final reporting date with each daily update and 
                       therefore seems likely to be a data handling error.")
              
            ),
            
            fluidRow(
              column(
                width=9,
                align="left",
                uiOutput("MeanAgeCasesTitle")
              ),
              column(
                width=3,
                align="right",
                downloadButton("CBA_MeanAge_download", "Download csv")
              )
            ),
            
            withSpinner(plotlyOutput("meanCasesByAgePlot", height="60vh"), type=7),
            
            fluidRow(
              column(
                width=9,
                align="left",
                uiOutput("AbsCasesByAgeTitle")
              ),
              column(
                width=3,
                align="right",
                downloadButton("CBA_Abs_download", "Download csv")
              )
            ),
            
            withSpinner(plotlyOutput("AbsCasesByAgePlot", height="60vh"), type=7)
          ),
         
          conditionalPanel(
            condition = "input.CBA_level == 2 || input.CBA_level == 3",
           
            fluidRow(
              column(
                width=9,
                align="left",
                uiOutput("LACasesByAgeTitle")
              ),
              column(
                width=3,
                align="right",
                downloadButton("CBA_LA_download", "Download csv")
              )
            ),
            
            withSpinner(plotlyOutput("LACasesByAgePlot", height="60vh"), type=7),
            
            fluidRow(
              column(
                width=9,
                align="left",
                uiOutput("LACaseRatesByAgeTitle")
              ),
              column(
                width=3,
                align="right",
                downloadButton("CBA_LA_rates_download", "Download csv")
              )
            ),
            
            withSpinner(plotlyOutput("LACaseRatesByAgePlot", height="60vh"), type=7)
          ),
          
          hr(),
          
          # "last updated" info
          fluidRow(
            column(
              width=12,
              align="right",
              uiOutput("updatedInfoAges")
            )
          ),
          
        width=9)
      )
    ),

    tabPanel(
      "March-June Pillar 1 tracker",
      value="tab_P1_tracker",
      
      # Sidebar with a slider inputs etc
      sidebarLayout(
        sidebarPanel(
          id = "sidePanel.p1.tracker",
          style = "overflow-y: auto; max-height: 100vh; position:relative;",
          
          h3("Area to highlight"),

          selectInput("utla.pillar1",
                      h5("Select an upper tier local authority to highlight:"),
                      choices = utlas.alphabetical,
                      selected = "Isle of Wight"
          ),

          hr(),

          h3("Details"),

          HTML("<h5>In May and June we were analysing the publicly available Public Health England data which
              was Pillar 1 (hospital) data only.
              We refined our method to handle the expected delays between onset of infection and having a 
              hospital swab test.
              The method is published <a href=\"http://www.thelancet.com/journals/landig/article/PIIS2589-7500(20)30241-7/fulltext\" target=\"_blank\">here</a> .</h5>"),
          
          h5("On 2nd July Public Health England changed to publishing the combined pillars 1 and 2 dataset, for which
             our delay functions were no longer appropriate (or as accurate, because the delays are more varied).
             In the 'Daily tracker' tab we use an adapted method tailored to the combined pillars dataset.
             We present here our March-June detailed analysis so that the results of the paper can be explored in more detail
             and to record a more accurate analysis of the timing of local epidemics over this period.
             Note that the gradual shift over this period from most cases being recorded as Pillar 1 to most cases being recorded
             as Pillar 2 means that the decrease in infections (hence decrease in R) towards the end is exaggerated."),

          h5("The nowcast combines the estimated R and number of new infections each week
             to approximate the number of new infections expected shortly after the given date. 
             It assumes no change in interventions so does not
             anticipate a lockdown starting or ending."),
          h5("The instantaneous reproduction number R
             is a measure of both the infectivity of the virus
             (expected to be roughly constant over this time frame)
             and the social network on which the virus is spreading.
             Decreasing our social contacts (social distancing, mask wearing, self-isolating)
             will reduce R; increasing social contacts will make it rise.
             When R is above 1 an epidemic will grow exponentially whereas when it is below 1 the epidemic will eventually die out.
             The further it is from 1, the faster these effects play out."),
          
          h5("All estimates of the number of infections are based directly on case counts so we are estimating
             the number of infected individuals who will go on to get a positive test, not the true total number
             of infections, which will almost certainly be higher. 
             We do not adjust for increasing testing capacity or the increasing role of Pillar 2 testing.
             The results here are intended more as a means of comparing between areas than
             as an exact representation of the number of infections.
             The apparent increasing R through the first half of March is likely an artefact of our method: we are not aware of any reasons to
             suppose that R was actually increasing during this time."),
          
          
          hr(),
          width=3
          ), # end sidebarPanel

        mainPanel(
          style = "overflow-y: auto; max-height: 100vh; position:relative;", 

          fluidRow(
            column(
              width=9,
              align="left",
              h3("Nowcast")
            ),
            column(
              width=3,
              align="right",
              downloadButton("downloadNowcast.p1", "Download csv")
            )
          ),

          withSpinner(plotlyOutput("p1ProjectionPlot", height="60vh"), type=7),

          hr(),
          fluidRow(
            column(
              width=9,
              align="left",
              h3("New infections")
            ),
            column(
              width=3,
              align="right",
              downloadButton("downloadIncidence.p1", "Download csv")
            )
          ),

          withSpinner(plotlyOutput("p1IncidencePlot", height="60vh"), type=7),

          hr(),

          fluidRow(
            column(
              width=9,
              align="left",
              h3("Instantaneous reproduction number R")
            ),
            column(
              width=3,
              align="right",
              downloadButton("downloadR.p1", "Download csv")
            )
          ),

          withSpinner(plotlyOutput("p1RPlot", height="60vh"), type=7),
          withSpinner(plotlyOutput("p1ROneUTLAPlot", height="60vh"), type=7),

          width=9
          ) # end mainPanel
          ) # end sidebarLayout
    ), # end "Pillar 1" tabPanel

    tabPanel(
      "March-June Pillar 1 synthetic controls",
      value="tab_synthetic_control",
      sidebarPanel(
        id="sidePanel.sc",
        style = "overflow-y: auto; max-height: 100vh; position:relative;", 
        
        h3("Area to highlight"),

        selectInput("areaSC",
                    h5("Select an upper tier local authority to highlight:"),
                    choices = utlas.alphabetical,
                    selected = "Isle of Wight"),



        prettyCheckboxGroup(
          inputId = "characteristics",
          label = h5("Match areas according to their reproduction number R in March-April and:"),
          choices = c("age profile"="a",
                      "ethnicity"="e",
                      "poverty indicators and density"="p"
                      ),
          selected = NULL,
          icon = icon("check-square-o"),
          status = "primary",
          outline = TRUE
        ),

        hr(),


        h3("Details"),

        h5("We create a 'synthetic control' for each area by combining other English areas in order to match
            as well as possible the target area's characteristics.
            In a sense, the synthetic control is the most similar area we can construct."),

        h5("The graph shows the difference between the estimated R in an area and the estimated R in the area's synthetic control.
           If the difference is negative, the area is doing better than the most similar area we could construct."),

        h5("We use Pillar 1 (hospital) data.
            As characteristics to match on, we always use the level of R and in addition you can choose to add age, ethnicity and/or deprivation -
            click on the checkboxes to add or drop the respective characteristic.
            This allows you to explore the robustness of the synthetic control approach."),
        h5("Choosing the matching variables isn't an exact science as it remains unclear
           which local characteristics predict epidemic severity.
           Matching on more variables isn't necessarily better as you risk
           assigning weight to characteristics that are unrelated to local epidemic
           severity. Additionally, the possibility of over fitting (better matching the
           pre-treatment data at the expense of the post treatment) increases."),
        
        HTML("<h5>Full details of the method are published <a href=\"http://www.thelancet.com/journals/landig/article/PIIS2589-7500(20)30241-7/fulltext\" target=\"_blank\">here</a>.</h5>"),


        hr(),
      width=3
      ),
      mainPanel(
        style = "overflow-y: auto; max-height: 100vh; position:relative;",
        
        withSpinner(plotlyOutput("SCPlot", height="85vh"), type=7),

      width=9
      )

    ), # end SC tabPanel

    tabPanel(
      "About",
      value="tab_about",
             style = "overflow-y: auto; height: 100%; position:relative;",
             withMathJax(includeMarkdown("markdown/about.md")),
             verbatimTextOutput("systeminfo") # server info
    ) # end "About" tab
  ) # end tabsetPanel
  
) # end ui


