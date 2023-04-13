#' A simple logging function
#'
#' @param message (string) The message to be logged
#' @param mode (string) type of log message (info / debug)
#' @return none

log_message <- function(message, mode="INFO") {
  if(mode == "DEBUG" && Sys.getenv("STATGPT_DEBUG") != "1") {
    return()
  }
  cat("[", mode, "] ", message, "\n")
}
