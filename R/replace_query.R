#' Replace query with completion
#'
#' This function captures the selected text as a query, along with code context
#' between line 0 and the selected line. Then a prompt is generated, and the
#' selected query is replaced with the result from the model.
#'
#' @return none

replace_query <- \() {

  # Get editor document context
  ctx <- getSourceEditorContext()

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
    modifyRange(getSourceEditorContext()$selection[[1]]$range, response$choices[[1]]$message$content)
  }
}
