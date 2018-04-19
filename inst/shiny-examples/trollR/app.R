library(shinydashboard)

shuffleButton <- function(id, label = "button1"){
  ns <- NS(id)
  tagList(
    actionButton(("reshuffle"), label = paste0("Classify Comment")),
    checkboxInput(("safespace"), label = h6("Safespace on"),value = FALSE)
  )
}

nice <- function(input) {
  token <- unlist(strsplit(input, " "))
  words <- token %in% shitwordlist
  token[words] <- gsub("[A-z]", replacement = "*", x = token[words])
  paste(token, collapse = " ")
}

server <-  function(input,output,session) {
  string <- eventReactive(input$reshuffle, {
    if(input$safespace == FALSE) input$testinput else
      if(input$safespace == TRUE) input$testinput %>% nice()
  })

  prob <- eventReactive(input$reshuffle, {
    (predict_troll(input$testinput)*100) %>% round(1)
  })

  output$value <- renderText({string()})

  output$gaugeee <- flexdashboard::renderGauge({
    flexdashboard::gauge(value = prob(), min = 0, max = 100, symbol = '%',
                         label = "Toxicity",
                         flexdashboard::gaugeSectors(
                           success = c(0, 25), warning = c(25,50), danger = c(75, 100),
                           colors = c("blue","green","red")
                         ))
  })
}

sbw = "30%" # CSS unit

ui <-
  dashboardPage(
    dashboardHeader(titleWidth = sbw,
                    title = "trollR - Online Trolling Detection"),
    dashboardSidebar(width = sbw,
                     textAreaInput(inputId = "testinput",
                                   label = "Comment", height = "20%", width = "100%",
                                   placeholder = "Please type your comment here."),
                     shuffleButton(id = "A")
    ),
    dashboardBody(
      fluidRow(
        box(title = "Submitted Comment",
            width = 8,
            solidHeader = TRUE,
            status = "primary",
            verbatimTextOutput("value")),
        box(title = "Troll Probability",
            height = 175,
            width = 4,
            solidHeader = TRUE, status = "primary",
            flexdashboard::gaugeOutput("gaugeee"))
      )
    )#,
    # tags$head(tags$style("#value{color: black;
    #                              font-size: 15px;
    #                              font-style: italic;
    #                              }"))

  )

shinyApp(ui = ui, server = server)



# Ideas: Safe-Mode

