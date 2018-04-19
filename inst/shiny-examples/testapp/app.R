library(shiny)

source("modules.R")

ui <- fixedPage(
  h2("Module example"),
  actionButton("insertBtn", "Insert module")
)

server <- function(input, output, session) {
  observeEvent(input$insertBtn, {
    btn <- input$insertBtn
    insertUI(
      selector = "h2",
      where = "beforeEnd",
      ui = tagList(
        h4(paste("Module no.", btn)),
        linkedScatterUI(paste0("scatters", btn)),
        textOutput(paste0("summary", btn))
      )
    )

    df <- callModule(linkedScatter,
                     paste0("scatters", btn),
                     reactive(mpg),
                     left = reactive(c("cty", "hwy")),
                     right = reactive(c("drv", "hwy"))
    )

    output$summary <- renderText({
      sprintf("%d observation(s) selected",
              nrow(dplyr::filter(df(), selected_)))
    })
  })
}

shinyApp(ui, server)
