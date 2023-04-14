
#' Get OpenAI model completion
#'
#' This function takes in a user query and a code context, then prompts the
#' provided OpenAI model to request a code completion via http request.
#'
#' @param prompt_query (string) the query to be sent to the AI model.
#' @param prompt_context (string) the code context for the query (optional).
#' @param API_KEY (string) the OpenAI API key.
#' @param MODEL (string) the name of the AI model (optional, default: 'gpt-3.5-turbo').
#' @param CONTEXT_LIMIT (integer) the total prompt limit in estimated tokens (optional, default: 2750)
#' @param TEMPERATURE (float) the model temperature ranging 0-2 (optional, default: 1)
#' @return (list) of (string) The model completion string

prompt_GPT <- \(prompt_query,
                prompt_context = "",
                API_KEY = Sys.getenv("OPENAI_API_KEY"),
                MODEL = Sys.getenv("OPENAI_MODEL", 'gpt-3.5-turbo'),
                CONTEXT_LIMIT = as.numeric(Sys.getenv("STATGPT_CTXLIM", 2750)),
                TEMPERATURE = as.numeric(Sys.getenv("OPENAI_TEMPERATURE", 0.25))
                ) {

  # Check if API_KEY is set, if not prompt the user
  if(!(nchar(API_KEY))) {
    API_KEY = showPrompt("OpenAI API KEY", "OPENAI_API_KEY was not found in the environment.\n\n Please set a key for this session.", default = NULL)
  }

  # Check if MODEL is set, if not, prompt the user
  if (!(nchar(MODEL))) {
    API_KEY = showPrompt("OpenAI Model", "MODEL was not found in the environment.\n\n Please set a model for this session.", default = "gpt-3.5-turbo")
  }

  if(!nchar(prompt_query)) {
    stop("[STATGPT] No prompt selected. Try again.")
  }

  # Prompt design
  STATGPT_QUERY <- paste("<QUERY>",prompt_query,"</QUERY>", sep = "")
  STATGPT_CONTEXT <- paste("<CODE>",prompt_context,"</CODE>", sep = "")
  STATGPT_SUFFIX <- "You are an R expert. Only respond with quality R code as plain text without code block syntax or backticks around it"
  STATGPT_PROMPT <- paste(STATGPT_CONTEXT, STATGPT_QUERY, STATGPT_SUFFIX, collapse="")

  # Use python-linked tiktoken lib to accurately truncate tokens
  STATGPT_PROMPT <- truncate_prompt(STATGPT_PROMPT, CONTEXT_LIMIT, MODEL)

  # Completion request settings
  parameters <- list(
    model = MODEL,
    temperature = TEMPERATURE
    )

  messages <- list(
    list(role = "user", content = STATGPT_PROMPT)
  )

  post_res <- POST(
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

  log_message(paste("Token Usage:\n","\tPrompt:",parsed_content$usage$prompt_tokens,
                  "\n\tCompletion:",parsed_content$usage$completion_tokens,
                  "\n\tTotal:",parsed_content$usage$total_tokens, "|", 4096),"DEBUG")

  return(parsed_content)
}
