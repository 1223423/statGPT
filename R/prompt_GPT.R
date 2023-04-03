library(httr)
library(jsonlite)

prompt_GPT <- \(prompt_query,
                prompt_context,
                API_KEY = Sys.getenv("OPENAI_API_KEY"),
                MODEL = Sys.getenv("OPENAI_MODEL"),
                CONTEXT_LIMIT = as.numeric(Sys.getenv("STATGPT_CTXLIM", 2750))
                ) {

  # Check if API_KEY, MODEL are defined
  if(!(nchar(API_KEY) && nchar(MODEL))) {
    stop("Either or both the API key and MODEL key are not set!")
  }

  # Prompt design
  STATGPT_QUERY <- paste("<QUERY>",prompt_query,"</QUERY>", sep = "")
  STATGPT_CONTEXT <- paste("<CODE>",prompt_context,"</CODE>", sep = "")
  STATGPT_SUFFIX <- "Only respond with code as plain text without code block syntax or backticks around it"
  STATGPT_PROMPT <- paste(STATGPT_CONTEXT, STATGPT_QUERY, STATGPT_SUFFIX, collapse="")
  char_token_ratio <- 3.2

  # Rough token estimate for token usage
  STATGPT_EST_TOKEN <- round(nchar(STATGPT_PROMPT)/char_token_ratio,0)
  #log_debug(paste("Estimated tokens:",STATGPT_EST_TOKEN))

  # Truncate code context if too many tokens are being used
  if(STATGPT_EST_TOKEN >= CONTEXT_LIMIT) {
    log_info(paste("Context limit (",CONTEXT_LIMIT,") exceeded (",STATGPT_EST_TOKEN,"). Context has been truncated.", sep = ""))
    cl <- nchar(STATGPT_PROMPT)
    STATGPT_PROMPT <- substr(STATGPT_PROMPT, cl-CONTEXT_LIMIT*char_token_ratio, cl)
  }

  # Rough estimate of tokens post truncation
  EST_TOKEN_TRUNC <- round(nchar(paste(STATGPT_PROMPT,STATGPT_SUFFIX,STATGPT_SYSTEM,collapse=""))/char_token_ratio,0)

  # Completion request settings
  parameters <- list(
    model = MODEL
    )

  messages <- list(
    list(role = "user", content = STATGPT_PROMPT)
  )

  post_res <- httr::POST(
    "https://api.openai.com/v1/chat/completions",
    add_headers("Authorization" = paste("Bearer", API_KEY)),
    content_type_json(),
    body = toJSON(c(parameters, list(messages = messages)), auto_unbox = TRUE)
    )

  ## Handling error codes
  if (!post_res$status_code %in% 200:299) {
    cat("[ERROR] Status Code:", post_res$status_code,"\n")
    stop(content(post_res))
  }

  parsed_content <- content(post_res)

  log_debug(paste("Estimated tokens:",STATGPT_EST_TOKEN,
                  "Estimated tokens (truncated):",EST_TOKEN_TRUNC,
                  "Token Usage:\n","\tPrompt:",parsed_content$usage$prompt_tokens,
                  "\n\tCompletion:",parsed_content$usage$completion_tokens,
                  "\n\tTotal:",parsed_content$usage$total_tokens, "|", CONTEXT_LIMIT))

  return(parsed_content)
}

