library(httr)
library(jsonlite)

prompt_GPT <- \(prompt,
                API_KEY = Sys.getenv("OPENAI_API_KEY"),
                MODEL = Sys.getenv("OPENAI_MODEL"),
                MAX_TOKENS = 2048) {

  # Check if API_KEY, MODEL and ORG are defined
  if(!(nchar(API_KEY) && nchar(MODEL))) {
    stop("Either or both the API key and MODEL key are not set!")
  }

  suffix = "Only respond with code as plain text without code block syntax or backticks around it"

  parameters <- list(
    model = MODEL,
    max_tokens = MAX_TOKENS)

  messages <- list(
    list(
      role = "system",
      content = "You are a machine translator of text into working code with extensive knowledge of R programming, statistics, and data visualization.
      You are given current code and the text, and only respond with code as plain text without code block syntax and backticks around it."
    ),
    list(role = "user", content = paste(prompt, suffix, collapse = ""))
  )

  post_res <- httr::POST(
    "https://api.openai.com/v1/chat/completions",
    add_headers("Authorization" = paste("Bearer", API_KEY)),
    content_type_json(),
    body = jsonlite::toJSON(c(parameters, list(messages = messages)), auto_unbox = TRUE)
    )

  ## Handling error codes
  if (!post_res$status_code %in% 200:299) {
    stop(content(post_res))
  }

  return(content(post_res))
}
