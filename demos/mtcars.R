library("teechart")
# dyn.load("inst/libs/x64/teechart.dll")

data <- mtcars
data$names <- rownames(data)

chart <- TeeChart$new(data = data, x = data$hp, y = data$qsec, texts = data$names)
chart$set_title("Engine Performance")$show()

