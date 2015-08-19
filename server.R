# Mandelbrot plotting function for shiny
library(shiny)
# Define the ramp functions that give us the colour and greyscale palettes
colour.ramp <- colorRampPalette(c("#000000", "#FF0000", "#FFFF00", "#00FFFF", "#0000FF"))
bw.ramp <- colorRampPalette(c("#000000", "#FFFFFF"))

shinyServer(    
    function(input, output, session) {
    
        # Session persistent variables
        v.centerx <- -0.5
        v.centery <- 0
        v.lastclicknonce <- 0
        v.currentzoom <- 1

        output$documentation <- renderText({
            "
            <p>This application allows an exploration of the Mandelbrot set</p>
            <p>This is the set of complex numbers C for which Z<sub>n+1</sub> = Z<sub>n</sub><sup>2</sup> + C does not tend toward infinity as successive iterations are performed. After the specified number of iterations are performed, those points that still have a finite value are colour coded and rendered as an image.</p>
            <p>Increasing the number of iterations performed provides increasing detail along the border of the finite numbers.</p>
            <p>Hover the mouse pointer over any of the controls for an explanation of its function.</p>
            <p>Select the 'Image' tab above to switch to the image view, click anywhere on the image, and lose yourself in the (nearly) infinite. The first image may take a few seconds to render, so please be patient.</p>
            <br>
            <br>The author wishes to acknowledge the use of the Mandelbrot algorithm published on Wikipedia
            <br><a href=https://en.wikipedia.org/wiki/R_(programming_language)>https://en.wikipedia.org/wiki/R_(programming_language)</a> 
            "
        })
        
        output$image <- renderPlot({
            # Check if we received a click from the graphic by comparing the input .nonce
            # value to the last saved value
            # if so then update the v.centerx, vcentery and v.lastclicknonce values
            if (!is.null(input$plot_click$.nonce)) { 
                if(input$plot_click$.nonce != v.lastclicknonce) {
                    v.lastclicknonce <<- input$plot_click$.nonce
                    
                    # Update the v.centerx and v.centery coordinates based upon the received $x and $y values
                    # contained in input$plot_click (these are referenced to the bottom left corner of the image)
                    v.rangemin <- v.centerx - (1 / v.currentzoom)
                    v.rangemax <- v.centerx + (1 / v.currentzoom)
                    v.centerx <<- v.rangemin + ((v.rangemax - v.rangemin) * input$plot_click$x)

                    v.rangemin <- v.centery - (1 / v.currentzoom)
                    v.rangemax <- v.centery + (1 / v.currentzoom)
                    v.centery <<- v.rangemin + ((v.rangemax - v.rangemin) * input$plot_click$y)        
                    
                    # Get the value of the GUI zoom control and use this to update v.currentzoom
                    v.guizoomstep <- as.numeric(input$zoom)
                    v.currentzoom <<- v.currentzoom * v.guizoomstep
                }   
            }
            
            # Get the remaining input controls settings
            # The output image resolution
            image.resolution <- as.numeric(input$imageresolution)
            # The number of iterations that we perform in the z <- z^2 + c calculation
            iterations <- input$iterations
            # Colour or greyscale output
            render.bw <- input$renderbw
            
            # The height / width of the Cartesian plane displayed in the image
            v.real.min <- v.centerx - (1 / v.currentzoom)
            v.real.max <- v.centerx + (1 / v.currentzoom)
            v.imag.max <- v.centery + (1 / v.currentzoom)
            v.imag.min <- v.centery - (1 / v.currentzoom)

            # Create the initial sequence of complex numbers based upon the max and min of the real
            # and imaginary axes ranges
            cplx.plane <- complex(real = rep(seq(v.real.min, v.real.max, length.out = image.resolution), each = image.resolution),
                                  imag = rep(seq(v.imag.min, v.imag.max, length.out = image.resolution), image.resolution))

            # Coerce the sequence of complex numbers into a matrix (so that they resemble a Cartesian plane)
            cplx.plane<- matrix(cplx.plane, image.resolution, image.resolution, byrow = TRUE)

            # Initialize the output results array to 0 
            results <- 0

            # Initialize the output image array to 0
            output.image <- array(0, c(image.resolution, image.resolution))

            # Iterate over results array performing the Z = Z^2 + C computation
            for (k in 1:iterations) {
                results <- results ^ 2 + cplx.plane
            }

            # Convert back to real numbers
            output.image <- exp(-abs(results))

            # Set the greyscale or colour palette for rendering the output
            if(render.bw == TRUE) {palette <- bw.ramp(256)} else {palette <- colour.ramp(65536)}

            # Set all margins to zero
            par(mar = c(0,0,0,0))

            # And render as a bitmapped image
            image(output.image, col = palette, useRaster=TRUE, axes = FALSE)
        },  height = 600, width = 600)
        
    }
)