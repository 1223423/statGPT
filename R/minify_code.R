#' Capture and minify code context
#'
#' Captures and minifies the code context (string) in order to save on token budget.
#' The code context is all code in the editor above 'currentLine', up to line 0.
#' Currently minification is rudimentary to ensure best results on inference.
#'
#' @param currentLine (integer) The currently selected line
#' @return (string) The code context, from line 0 to currentLine, minified

minify_code <- \(currentLine) {

  # Get raw code context
  ctx_code <- rstudioapi::getSourceEditorContext()$content[1:currentLine-1]

  # Remove leading whitespace
  ctx_code <- unlist(lapply(ctx_code, \(s) sub("^\\s+", "", s)))

  # Remove explicit comment lines
  ctx_code <- ctx_code[sapply(ctx_code, \(s) return(substr(s,1,1) != '#'))]

  # Remove empty lines
  ctx_code <- ctx_code[ctx_code != ""]
  ctx_collapsed <- paste(ctx_code, collapse = "")

  return(ctx_collapsed)
}
