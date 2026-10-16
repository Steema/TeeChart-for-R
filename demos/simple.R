data <- c(10, 25, 15, 30, 22)
texts <- c("A", "B", "C", "D", "E")

chart <- TeeChart$new(x = x_vals, y = data, texts = texts)
chart$show()
