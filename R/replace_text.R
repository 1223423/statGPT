replace_text <- function() {

  # Get document context
  ctx <- rstudioapi::getSourceEditorContext()

  # Checks that a document is active
  if (!is.null(ctx)) {

    # Extracts selection as a string
    selected_text <- ctx$selection[[1]]$text

    currentLine = ctx$selection[[1]]$range[[1]][1]
    code_context <- paste(list(ctx$content)[1:currentLine-1], collapse = "")

    prompt_query = paste("[USER REQUEST BEGIN]",selected_text,"[USER REQUEST END]")
    prompt_context = paste("[CODE BEGIN]",code_context, "[CODE END]")
    response <- prompt_GPT(prompt = paste(prompt_query,prompt_context))

    log_debug(paste("Response:\n\t",response$choices[[1]]$message$content))

    # replaces selection with string
    rstudioapi::modifyRange(rstudioapi::getSourceEditorContext()$selection[[1]]$range, response$choices[[1]]$message$content)
  }
}

#plot(mtcars$hp, mtcars$mpg)






