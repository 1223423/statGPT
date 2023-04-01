log_debug <- \(message) {
  if(Sys.getenv("STATGPT_DEBUG") == "1") cat("[DEBUG] ",message,"\n")
}

log_info <- \(message) {
  cat("[INFO] ",message,"\n")
}
