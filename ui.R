library(shiny)
shinyUI(fluidPage(
    headerPanel("Mandelbrot Explorer"),
    sidebarPanel(
        helpText("Hover over a control to see tooltip help"),

        tags$div(title="Control the number of iterations performed, a higher number takes more time but yields more detailed images",
                selectInput('iterations', 'Iteration Count', c('10' = 10,
                                                            '20' = 20,
                                                            '30' = 30,
                                                            '40' = 40,
                                                            '50' = 50,
                                                            '60' = 60,
                                                            '70' = 70,
                                                            '80' = 80,
                                                            '90' = 90,
                                                            '100' = 100
                ), selected = 20)
        ),
                
        tags$div(title="Control what happens when the image is clicked on, center or center and zoom in / out ",
                 selectInput('zoom', 'Click Action', c('center & zoom -5' = 0.2,
                                                       'center & zoom -2' = 0.5,
                                                       'center & no zoom' = 1,
                                                       'center & zoom +2' = 2,
                                                       'center & zoom +5' = 5
                 ), selected = 2)
        ),
        
        tags$div(title="Control the image resolution, higher resolution takes more time and resources but shows more detail",
                selectInput('imageresolution', 'Image Resolution', c('200 x 200' = 200, '400 x 400' = 400, '600 x 600' = 600),
                    selected = 400)
        ),
        
        tags$div(title="Control the palette used when rendering the image, colour or greyscale",
                 selectInput('renderbw', 'Palette', c('greyscale' = TRUE, 'colour' = FALSE), selected = FALSE)
        )
    ),
    mainPanel(
        tabsetPanel(
            tabPanel("Information", htmlOutput('documentation')),
            tabPanel("Image", plotOutput('image', click = "plot_click"))
        )
    )
))
