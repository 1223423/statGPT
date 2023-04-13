#' Pass selected text as query, along with code context above that line
#' and replace it with OpenAI code completion
#'
#' @return none
#' @examples
#' replace_query()
#'

replace_query <- \() {

  # Get editor document context
  ctx <- rstudioapi::getSourceEditorContext()

  # Check that the document is active
  if (!is.null(ctx)) {

    # Find currently selected line
    currentLine = ctx$selection[[1]]$range[[1]][1]

    # Extract selection as a string
    prompt_query <- ctx$selection[[1]]$text

    # Get all code preceding selected line(s) and minify the code
    prompt_context = minify_code(currentLine)

    # Capture model response
    response <- prompt_GPT(prompt_query, prompt_context)

    # Replace selected line(s) with model response
    rstudioapi::modifyRange(rstudioapi::getSourceEditorContext()$selection[[1]]$range, response$choices[[1]]$message$content)
  }
}



