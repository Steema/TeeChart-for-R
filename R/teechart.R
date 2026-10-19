#' @useDynLib teechart, .registration = TRUE
NULL

#' R6 class
#  @importFrom R6 R6Class
#' @export
TeeChart <- R6::R6Class(
  "TeeChart",
  public = list(
    x = NULL,
    y = NULL,
    z = NULL,
    texts = NULL,
    data = NULL,
    title = "",
    footer = "",
    color = "",

    initialize = function(x = NULL, y, z = NULL, texts = NULL, data = NULL, ...) {

     if (!is.null(data)) {
         if (!missing(x)) self$x <- eval(substitute(x), data, parent.frame())
         if (!missing(y)) self$y <- eval(substitute(y), data, parent.frame())
         if (!missing(z)) self$z <- eval(substitute(z), data, parent.frame())

         if (!missing(texts)) self$texts <- eval(substitute(texts), data, parent.frame())
     } else {
       if (is.null(x)) {
          self$x <- numeric(0)
        } else {
          self$x <- as.numeric(x)
       }

       self$y <- as.numeric(y)

       if (is.null(z)) {
          self$z <- numeric(0)
        } else {
          self$z <- as.numeric(z)
       }

       if (is.null(texts)) {
          self$texts <- rep("", length(self$y))
       } else {
          self$texts <- as.character(texts)
       }
     }

     args <- list(...)
      if (!is.null(args$title)) self$title <- args$title
      if (!is.null(args$footer)) self$footer <- args$footer
      if (!is.null(args$color)) self$color <- args$color
     },

     render = function(output_type = "form", width = 800, height = 600) {

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
                as.character(self$title),
                as.character(self$footer),
                PACKAGE = "teechart"
      )

      invisible(res)
    },

    show = function() {
      self$render(output_type = "form")
    },

    set_title = function(new_title) {
      self$title <- new_title
      invisible(self)
    },

    set_footer = function(new_footer) {
      self$footer <- new_footer
      invisible(self)
    },

    set_color = function(new_color) {
      self$color <- new_color
      invisible(self)
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
  cat("<TeeChart> with", length(x$y), "points\n")
  invisible(x)
}