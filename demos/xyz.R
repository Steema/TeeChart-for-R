library("teechart")

x <- seq(-3, 3, length.out = 30)
y <- seq(-3, 3, length.out = 30)

xyz <- expand.grid(x = x, y = y)
xyz$z <- sin(sqrt(xyz$x^2 + xyz$y^2))

chart <- TeeChart$new(x = x, y = y, z = xyz$z, commander = TRUE)
chart$set_title("XYZ 3D Surface")$show()

