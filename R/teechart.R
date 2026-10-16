#' @useDynLib teechart, .registration = TRUE
NULL

#' R6 class
#' @export
TeeChart <- R6::R6Class(
  "TeeChart",
  public = list(
    x = NULL,
    y = NULL,
    texts = NULL,

    initialize = function(x = NULL, y, texts = NULL) {
      self$x <- as.numeric(x)
      self$y <- as.numeric(y)
      self$texts <- as.character(texts)
    },

    render = function(output_type = "png", width = 800, height = 600) {

      # output_type "png" or "jpeg" or "jpg" or "form"
      res <- .C("TeeChartRender",
                as.integer(length(self$x)),
                as.double(self$x),
                as.integer(length(self$y)),
                as.double(self$y),
                as.integer(length(self$texts)),
                as.character(self$texts),
                as.character(output_type),
                as.integer(width),
                as.integer(height),
                PACKAGE = "teechart"
      )

      invisible(res)
    },

    show = function() {
      self$render(output_type = "form")
    }
  )
)

#' @export
plot.TeeChart <- function(x, y, ...) {
  # Use R grid or graphics to paint the png
  png_data <- x$render(output_type = "png", ...)

  grid::grid.raster(png_data)
  invisible(x)
}

#' @export
print.TeeChart <- function(x, ...) {
  invisible(x)
}