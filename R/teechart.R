#' @useDynLib teechart
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
    style = "",
    horiz = FALSE,
    commander = FALSE,
    opengl = FALSE,
    png = NULL,

    initialize = function(x = NULL, y, z = NULL, texts = NULL, data = NULL, ...) {

     if (!is.null(data)) {
         self$data <- data

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
      if (!is.null(args$style)) self$style <- args$style
      if (!is.null(args$horiz)) self$horiz <- args$horizontal
      if (!is.null(args$commander)) self$commander <- args$commander
     },

     render = function(output_type = "form", width = 800, height = 600) {

      # output_type "png" or "jpeg" or "jpg" or "form" (modal) or "window" (non-modal)
      res <- .C("TeeChartRender",
                as.integer(length(self$x)),   as.double(self$x),
                as.integer(length(self$y)),   as.double(self$y),
                as.integer(length(self$z)),   as.double(self$z),
                as.integer(length(self$texts)),  as.character(self$texts),

                as.character(output_type),
                as.integer(width),
                as.integer(height),
                as.character(self$style),
                as.character(self$title),
                as.character(self$footer),
                as.logical(self$horiz),
                as.logical(self$commander),
                as.logical(self$opengl),
                PACKAGE = "teechart"
      )

      if (output_type == "png") {
        b <- .C("TeeChartGetBytes",
           buf = raw(res$size),
           n   = as.integer(res$size),
           PACKAGE = "teechart")

        self$png <- b$buf
      }

      invisible(res)
    },

    show = function(modal = TRUE) {
      if (modal)
         self$render(output_type = "form")
      else
         self$render(output_type = "window")
    },

    set_opengl = function(enabled = TRUE) {
      self$opengl <- enabled
      invisible(self)
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
plot.TeeChart <- function(chart, ...) {
  # Use R grid or graphics to paint the png
  png_data <- chart$render(output_type = "png", ...)

  grid::grid.raster(png_data)
  invisible(chart)
}

#' @export
print.TeeChart <- function(chart, ...) {
  cat("<TeeChart> with", length(chart$y), "points\n")
  invisible(chart)
}

