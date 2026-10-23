set.seed(42)

n <- 1000

a <- rnorm(n, mean = 50, sd = 10)
b <- rnorm(n, mean = 50, sd = 10)
c <- rnorm(n, mean = 50, sd = 10)

chart <- TeeChart$new(data = data.frame(a, b, c), style = "FastLine")

chart$show()

