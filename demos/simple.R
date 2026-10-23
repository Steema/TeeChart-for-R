library("teechart")

data <- c(10, 25, 15, 30, 22)
texts <- c("A", "B", "C", "D", "E")

chart <- TeeChart$new(y = data, texts = texts, style = "pie", title = "TeeChart Pie")
chart$show()
