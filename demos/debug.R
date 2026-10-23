library(teechart)

# dyn.load("inst/libs/x64/teechart.dll")

is.loaded("TeeChartRender")

.C("TeeChartRender", 3L, c(1,2,3), 3L, c(4,5,6), 3L, c("a","b","c"),
   "png", 800L, 600L)
