#' @param img Vector of character file names or list of \code{nifti} images
#' @param elementId ID for the element in the DOM
#' @param width Width of the widget
#' @param height height of the widget
#' @param options to pass to papaya widget.  Should be a list with
#' the same number of elements as images passed in.  Options can
#' be generated using \code{\link{papayaOptions}}
#'
#'
#' @title Creating a Papaya widget
#'
#' @description Wraps a widget for the Papaya JavaScript library
#'
#' @import htmlwidgets
#'
#' @export
#' @importFrom neurobase checkimg
#' @importFrom base64enc base64encode
#' @importFrom jsonlite toJSON
#' @examples
#' img = kirby21.t1::get_t1_filenames()[1]
#'
#' papaya(img, options = papayaOptions(min = 0, max = 5e5))
#' papaya(c(img, img),
#' options = list(papayaOptions(alpha = 0.5),
#' papayaOptions(alpha = 0.5, lut = "Red Overlay"))
#' )
#'
#'
papaya <- function(
  img = NULL,
  elementId = NULL,
  width = NULL, height = NULL,
  options = NULL
  # ,
  # options = papayaOptions()) {
){

  if (!is.null(img)) {
    img = checkimg(img, allow_array = TRUE)
    fileData = sapply(img, base64enc::base64encode)
    fileData <- jsonlite::toJSON(fileData)
  } else {
    fileData = NULL
  }
  if (is.null(elementId)) {
    elementId = basename(tempfile())
  }
  if (!is.null(options)) {
    n_options = length(options)
    n_imgs = length(img)
    if (n_imgs > 1) {
      assert_that(n_options == n_imgs)
    } else {
      options = list(options)
    }
    # options = fileData <- jsonlite::toJSON(fileData)
  }

  x <- list(
    index = 0,
    id = elementId,
    images = fileData,
    options = options
  )


  # create widget
  htmlwidgets::createWidget(
    name = 'papayaWidget',
    x = x,
    width = width,
    height = height,
    package = 'papayaWidget',
    elementId = elementId
  )
}

#' Shiny bindings for papayaWidget
#'
#' Output and render functions for using papayaWidget within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a papayaWidget
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name papayaWidget-shiny
#'
#' @export
papayaOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, "papayaWidget", width,
                                 height, package = "papayaWidget")
}

#' @rdname papayaWidget-shiny
#' @export
renderPapaya <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, papayaOutput, env, quoted = TRUE)
}
