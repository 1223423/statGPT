#' Replace selection text with code completion
#'
#' @return (string) code completion inside the editor
#' @export
#'
#' @examples
#'
#'


replace_text <- function() {

  # Get document context
  ctx <- rstudioapi::getSourceEditorContext()

  # Checks that a document is active
  if (!is.null(ctx)) {

    # Find current line
    currentLine = ctx$selection[[1]]$range[[1]][1]

    # Extract selection as a string
    prompt_query <- ctx$selection[[1]]$text

    prompt_context = get_minified_code(currentLine)

    response <- prompt_GPT(prompt_query, prompt_context)

    # Replace selection with response
    rstudioapi::modifyRange(rstudioapi::getSourceEditorContext()$selection[[1]]$range, response$choices[[1]]$message$content)
  }
}

#' Rudimentary minification of code
#'
#' @param currentLine (integer) line number of selected text
#'
#' @return (string) code context with whitespace and explicit comments removed
#' @export
#'
#' @examples
#'
#'

get_minified_code <- \(currentLine) {

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


