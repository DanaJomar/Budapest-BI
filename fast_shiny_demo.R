library(shiny)
available_data <- data()$results
choices <- available_data[, 3] %>% 
  sapply(function(x) 
    strsplit(x, ' ')[[1]][1]) %>% 
  unname()

choices <- choices[choices %>%
                     sapply(function(x) 
                       any(class(get(x)) %in% c('matrix', 'data.frame'))) %>% 
                     unlist]

make_css(list('tr:hover', 
              c('background-color', 'color'), 
              c('#cc0000!important', 'white!important')), 
         file = '../mycss.css')

ui <- fluidPage(
  fluidRow(
    column(width = 2,
           selectInput('df', 'Select Data', 
                       choices = choices,
                       selected = 'mtcars'),
           uiOutput('columns')
    ),
    column(width = 10,
           tableHTML_output('mytable'),
           includeCSS('../mycss.css')
    )
  )
)

server <- function(input, output){
  my_data <- reactive(get(input$df))
  
  output$columns <- renderUI({
    selectInput('col', 'Columns', multiple = TRUE,
                choices = colnames(my_data()))
  })
  output$mytable <- render_tableHTML({
    tableHTML(my_data() %>% 
                head(20), 
              widths = c(150, rep(100, ncol(my_data()))), 
              caption = available_data[, 4][which(grepl(input$df , available_data[, 3]))]) %>% 
      add_css_column(css = list('background-color', 'lightblue'), columns = input$col)
    }
  )
}

shinyApp(ui, server)

#
#
# add_css_column(css = list('background-color', 'lightblue'), columns = input$col)
# add_css_caption(css = list(c('font-size', 'color', 'background-color'), c('25px', 'black', 'lightyellow')))