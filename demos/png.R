library("teechart")

data <- c(10, 25, 15, 30, 22)
texts <- c("A", "B", "C", "D", "E")

chart <- TeeChart$new(y = data, texts = texts, style = "area", title = "PNG image")

chart$render(output_type = "png")

install.packages("png")

grid::grid.raster(png::readPNG(chart$png))


