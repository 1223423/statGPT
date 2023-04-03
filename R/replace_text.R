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
    #prompt_context = paste("[CODE BEGIN]",code_context, "[CODE END]")
    response <- prompt_GPT(prompt_query, prompt_context)

    log_debug(paste("Response:\n\t",response$choices[[1]]$message$content))

    # Replace selection with response
    rstudioapi::modifyRange(rstudioapi::getSourceEditorContext()$selection[[1]]$range, response$choices[[1]]$message$content)
  }
}

# Simple minification
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

  ctx_est_tokens <- nchar(ctx_collapsed)/4
  log_debug(paste("Estimated minified ctx tokens: ", ctx_est_tokens))

  return(ctx_collapsed)
}


