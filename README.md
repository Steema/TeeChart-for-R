# TeeChart-for-R

## Add Charts and Plots to your R projects

TeeChart for R is a free package that uses the [TeeChart library](https://www.steema.com/).

The standard version includes most common chart styles:

<img width="455" height="400" alt="image" src="https://github.com/user-attachments/assets/d7b3ae17-0038-4409-a564-de3a5caa0ed9" />


Tested with [R 4.6.1](https://www.r-project.org/)

Use R console, RGui or [RStudio ide](https://posit.co/downloads), set your default workspace or folder to this repository on your local machine, and run R:

```
> library("teechart")

Run a simple example to show a chart:

> source("demos/simple.R")

data <- c(10, 25, 15, 30, 22)
texts <- c("A", "B", "C", "D", "E")

chart <- TeeChart$new(y = data, texts = texts)
chart$show()

```

<img width="1195" height="1590" alt="image" src="https://github.com/user-attachments/assets/236ee942-d8ca-4d0f-af95-ea04f5e0b028" />


## A pro version (not yet available) provides extended support with many more styles and functionality like 3D charts:

<img width="978" height="621" alt="image" src="https://github.com/user-attachments/assets/03258950-cae9-467c-b587-2f16b44b3cdc" />

<img width="1263" height="1148" alt="image" src="https://github.com/user-attachments/assets/2f1431d1-d8b0-49b0-8fad-cc68c73333b2" />



