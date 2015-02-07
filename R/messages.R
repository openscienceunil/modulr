.reverse <- function(x) sapply(lapply(strsplit(x, NULL), rev), paste,
                               collapse="")

.cuts <- function(string, revert = F, ...) {
  if(revert) string <- .reverse(string)
  lines <- unlist(strwrap(string, simplify = F, ...))
  last_line <- tail(lines, 1L)
  if(length(lines) > 1) {
    first_lines <- paste(head(lines, -1), collapse = "\n")
  } else first_lines <- NULL
  if(revert) {
    first_lines <- sapply(first_lines, .reverse)
    last_line <- .reverse(last_line)
  }
  list(
    first_lines = first_lines,
    last_line = last_line
  )
}

.message_reopen <- function(handler) {
  assign("message_handler", handler, pos = modulr_env)
  if(!is.null(handler))
    if(handler$output) {
      if(!is.null(handler$first_lines))
        #message(handler$first_lines)
        cat(handler$first_lines, sep="\n")
      #message(handler$last_line, appendLF = F)
      cat(handler$last_line, sep="")
    }
}

message_open <- function(announce, output = T, ...) {
  cut <- .cuts(paste0("[", Sys.time(), "] ", announce),
               width = 0.9 * getOption("width"), ...)
  handler <- list(
    first_lines = cut$first_lines,
    last_line = cut$last_line,
    output = output,
    args = list(...)
  )
  assign("message_handler", handler, pos = modulr_env)
  assign("message_closed", "", pos = modulr_env)
  .message_reopen(handler)
}

.message <- function(f, type = "INFO", ...) {
  handler <- get("message_handler", pos = modulr_env)
  closed <- get("message_closed", pos = modulr_env)
  if(!is.null(handler) & closed != type) {
    message_close(type)
    assign("message_handler", handler, pos = modulr_env)
    assign("message_closed", type, pos = modulr_env)
  }
  f(...)
}

.dots_print <- function(...) {
  handler <- get("message_handler", pos = modulr_env)
  if(is.null(handler))
    prefix = paste0("[", Sys.time(), "] ")
  else
    prefix = ""
  cat(unlist(strwrap(paste0(prefix, ...),
                     width=0.9 * getOption("width"))),
      sep = "\n")
}

message_info <- function(...) .message(.dots_print, type = "INFO", ...)
message_warn <- function(...) .message(.dots_print, type = "WARN", ...)
message_stop <- function(...) {
  .message(.dots_print, type = "STOP", ...)
  stop("modulr stopped.", call. = F)
}

# message_info <- function(...) .message(message, type = "INFO", ...)
# message_warn <- function(...) .message(
#   function(...) warning(..., immediate. = T), type = "WARN", ...)
# message_stop <- function(...) .message(stop, type = "STOP", ...)

message_close <- function(result) {
  handler <- get("message_handler", pos = modulr_env)
  if(!is.null(handler)) {
    closed <- get("message_closed", pos = modulr_env)
    if(closed != "") {
      .message_reopen(handler)
      assign("message_closed", "", pos = modulr_env)
    }
    if(handler$output) {
      cut <- do.call(.cuts, args =
                       c(list(result, revert = T, width = 0.9 * getOption("width")),
                         handler$args))
      n_dots <-
        0.9 * getOption("width") - nchar(handler$last_line) - nchar(cut$last_line)
      if(n_dots<3) {
        dots <-
          paste(
            paste(rep(".", max(0,
                               0.9 * getOption("width") - nchar(handler$last_line))),
                  collapse=""),
            paste(rep(".", max(3, 0.9 * getOption("width") - nchar(cut$last_line))),
                  collapse=""),
            sep = "\n")
      } else {
        dots <- rep(".", n_dots)
      }
      #message(dots, cut$last_line)
      cat(dots, cut$last_line, "\n", sep="")
      if(length(cut$first_lines) > 0)
        #message(cut$first_lines)
        cat(cut$first_lines, "\n", sep="")
    }
  }
  assign("message_handler", NULL, pos = modulr_env)
}