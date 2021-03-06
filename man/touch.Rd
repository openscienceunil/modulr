% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/make.R
\name{touch}
\alias{touch}
\title{Touch a Module.}
\usage{
touch(name = .Last.name)
}
\arguments{
\item{name}{A string (character vector of lenght one).

  A module name can contain letters, figures and some special characters,
  namely \code{_}, \code{-}, and \code{/}. The latter is a namespace
  separator.

  Names containing \code{/mock/}, \code{/mocks/}, \code{/test/},
  \code{/tests/}, \code{/example/}, or \code{/examples/} have a special
  meaning related to code testing and examples.

  The name "modulr" corresponds to a special module and is therefore
  reserved.}
}
\description{
Touch a module by marking it as outdated and by resetting its default
configuration, if appropriate.
}
\details{
See \code{\link{make}} and \code{\link{module_options}}.
}
\section{Warning}{

 It is considered a very bad practice to define, touch, undefine, load, make,
 reset, or perform any other operation from within a module definition that
 may alterate the internal state of modulr.
}

\examples{
reset()
define("foo", NULL, function() format(Sys.time(), "\%H:\%M:\%OS6"))
make()
make()
touch()
make()

reset()
define("A", NULL, function() "(A)")
define("B", NULL, function() "(B)")
define("C", list(a = "A"), function(a) paste0("(", a, "C)"))
define("D", list(a = "A", b = "B"), function(a, b) paste0("(", a, b, "D)"))
define("E", list(d = "D"), function(d) paste0("(", d, "E)"))
define("F", list(c = "C", d = "D", e = "E"),
  function(c, d, e) paste0("(", c, d, e, "F)"))
make()
touch("B")
make("F")
plot_dependencies()

reset()
define("foo", list(bar = "bar"), function(bar) bar)
define("bar#1.0.0", NULL, function() "bar v1.0.0")
define("bar#1.0.1", NULL, function() "bar v1.0.1")
make("foo")
maps_config$set(foo = list("bar" = "bar#1.0.0"))
make("foo")
touch("foo")
make("foo")

}
\seealso{
\code{\link{.Last.name}}, \code{\link{plot_dependencies}},
  \code{\link{make}}, \code{\link{module_options}},
  and \code{\link{reset}}.
}
