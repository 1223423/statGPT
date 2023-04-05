
#' Get OpenAI model completion via http
#'
#' @param prompt_query (string) the query to be sent to the AI model.
#' @param prompt_context (string) the code context for the query (optional).
#' @param API_KEY (string) the OpenAI API key.
#' @param MODEL (string) the name of the AI model (optional, default: 'gpt-3.5-turbo').
#' @param CONTEXT_LIMIT (integer) the total prompt limit in estimated tokens (optional, default: 2750)
#' @param TEMPERATURE (float) the model temperature ranging 0-2 (optional, default: 1)
#'
#' @return (list) of (string) The model completion string
#' @export
#'
#' @examples
#'
#'
#'

prompt_GPT <- \(prompt_query,
                prompt_context = "",
                API_KEY = Sys.getenv("OPENAI_API_KEY"),
                MODEL = Sys.getenv("OPENAI_MODEL", 'gpt-3.5-turbo'),
                CONTEXT_LIMIT = as.numeric(Sys.getenv("STATGPT_CTXLIM", 2750)),
                TEMPERATURE = as.numeric(Sys.getenv("OPENAI_TEMPERATURE", 1))
                ) {

  # Check if API_KEY, MODEL are defined
  if(!(nchar(API_KEY) && nchar(MODEL))) {
    stop("Either or both the API key and MODEL key are not set!")
  }

  # Prompt design
  STATGPT_QUERY <- paste("<QUERY>",prompt_query,"</QUERY>", sep = "")
  STATGPT_CONTEXT <- paste("<CODE>",prompt_context,"</CODE>", sep = "")
  STATGPT_SUFFIX <- "You are an R expert. Only respond with quality R code as plain text without code block syntax or backticks around it"
  STATGPT_PROMPT <- paste(STATGPT_CONTEXT, STATGPT_QUERY, STATGPT_SUFFIX, collapse="")

  # Use python-linked tiktoken lib to accurately truncate tokens
  STATGPT_PROMPT <- truncated_prompt(STATGPT_PROMPT, CONTEXT_LIMIT, MODEL)

  # Completion request settings
  parameters <- list(
    model = MODEL,
    temperature = TEMPERATURE
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

  log_debug(paste("Token Usage:\n","\tPrompt:",parsed_content$usage$prompt_tokens,
                  "\n\tCompletion:",parsed_content$usage$completion_tokens,
                  "\n\tTotal:",parsed_content$usage$total_tokens, "|", CONTEXT_LIMIT)
                  )

  return(parsed_content)
}

truncated_prompt <- \(prompt, CONTEXT_LIMIT, MODEL) {

  env = "r-statGPT"
  v_req = "3.8"

  # Create the environment if it doesn't exist
  if (!env %in% conda_list()$name) {
    conda_create(env, python_version = v_req)
  }

  # Activate the Conda environment
  use_condaenv(env)

  # Check Python version in the environment
  python_version <- py_config()$version
  if (python_version < v_req) {
    stop(paste("Python version in the environment is",
               python_version,
               "but the required version is",
               v_req,
               "or higher."))
  }

  # Install the tiktoken package if it's not already installed
  if (!py_module_available("tiktoken")) {
    conda_install(env, "tiktoken")
  }

  # Use py tiktoken
  tiktoken <- import("tiktoken")
  encoder <- tiktoken$encoding_for_model(MODEL)
  tokenized <- encoder$encode(prompt)

  if(length(tokenized) > CONTEXT_LIMIT) {
    log_info(paste("Context (",length(tokenized),
                   ") has been truncated as it exceeds the limit (",
                   CONTEXT_LIMIT, ")", sep = ""))
  }

  # Truncate and decode
  tokenized <- tokenized[1:min(length(tokenized),CONTEXT_LIMIT)]
  untokenized <- encoder$decode(tokenized)

  # Adjust token overhead
  # Reference: openai-cookbook/examples/How_to_count_tokens_with_tiktoken.ipynb

  # default tpm
  tokens_per_message = 4

  if(grepl("gpt-3.5", MODEL, ignore.case = T)) {
    #log_info("Warning: gpt-3.5-turbo may change over time. Returning num tokens assuming gpt-3.5-turbo-0301.")
    tokens_per_message = 4
  }

  else if(grepl("gpt-4", MODEL, ignore.case = T)) {
    tokens_per_message = 3
  }

  overhead_tokens = 3
  user_tokens = 1

  log_debug(paste("Tokenized length:", length(tokenized) + tokens_per_message + overhead_tokens + user_tokens))

  return(untokenized)
}
