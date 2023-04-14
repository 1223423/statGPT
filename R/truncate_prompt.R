#' Truncate the code context
#'
#' This function truncates the code context as accurately as possible in order to
#' maintain as large a context as possible. This is done through linked Python
#' code using OpenAI's tiktoken package. statGPT attempts to set up it's own
#' python environment with the correct version and install the requirements if
#' they aren't already.
#'
#' @param prompt (string) The complete prompt, including user query and context
#' @param CONTEXT_LIMIT (integer) The token limit (depends on model being used)
#' @param MODEL (string) The Open AI model being used
#' @return (string) Truncated prompt that will fit inside the token limit

truncate_prompt <- \(prompt, CONTEXT_LIMIT, MODEL) {

  # Configure statGPT's virtual Python environment
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

  # Inform the user if the context is being truncated
  if(length(tokenized) > CONTEXT_LIMIT) {
    log_message(paste("Context (",length(tokenized),
                   ") has been truncated as it exceeds the limit (",
                   CONTEXT_LIMIT, ")", sep = ""), "DEBUG")
  }

  # Truncate and untokenize
  tokenized <- tokenized[1:min(length(tokenized),CONTEXT_LIMIT)]
  untokenized <- encoder$decode(tokenized)

  # Adjust token overhead
  # Reference: openai-cookbook/examples/How_to_count_tokens_with_tiktoken.ipynb

  # default tokens per message
  tokens_per_message = 4

  if(grepl("gpt-3.5", MODEL, ignore.case = T)) {
    log_message("Warning: gpt-3.5-turbo may change over time. Returning num tokens assuming gpt-3.5-turbo-0301.", "DEBUG")
    tokens_per_message = 4
  }

  else if(grepl("gpt-4", MODEL, ignore.case = T)) {
    tokens_per_message = 3
  }

  overhead_tokens = 3
  user_tokens = 1

  log_message(paste("Tokenized prompt length:", length(tokenized) + tokens_per_message + overhead_tokens + user_tokens), "DEBUG")

  return(untokenized)
}
