<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Build Status](https://travis-ci.org/aclemen1/modulr.svg)](https://travis-ci.org/aclemen1/modulr)

modulr — A Dependency Injection (DI) Framework for R
====================================================

Description
-----------

The `modulr` package is a Dependency Injection (DI) Framework for R. By design, `modulr` allows to break down sequential programs into discrete, modular units that are loosely coupled, simple to develop, test, reuse and share in a wide range of situations. As every DI framework, it aims for a clear separation between code complication and complexity, highlighting the core purpose and behaviour of objects (application code), and hiding their construction and wiring (infrastructure code).

Advantages
----------

-   modules are easy (and fun) to develop,
-   modules are easy to debug,
-   modules are easy to test,
-   modules are easy to read,
-   modules are easy to reuse,
-   modules are easy to share,
-   modules are easy to maintain, and
-   modules force (a bit) to keep up with good practices.

History
-------

`modulr` has been developed by the [University of Lausanne](http://www.unil.ch) in Switzerland. The main goal of this package was to support the production of the institutional statistics and sets of indicators. Streamlined industrialization of data-related processes, agility, reusability and coding with fun in a distributed development environment were the first requirements.

`modulr` is in production for several months as by August 2015, with unprecedented results and great adoption among various teams. Therefore, we are thrilled to open the code and share it with the vibrant community of R users, teachers, researchers, and developers.

`modulr` is deeply inspired from [AngularJS](https://angularjs.org/) and [RequireJS](http://requirejs.org) for Javascript, as well as [guice](https://github.com/google/guice) for Java.

Installation
------------

You can install:

-   the latest released version from CRAN with

``` r
install.packages("modulr")
```

-   the latest development version from github with

    ``` r
    if (packageVersion("devtools") < 1.6) {
      install.packages("devtools")
    }
    devtools::install_github("aclemen1/modulr")
    ```

If you encounter a clear bug, please file a minimal reproducible example on github.

A short example
---------------

To get started with `modulr`, let us consider the following situation. Suppose that a university needs to compute its student-teacher ratio. This requires to gather at least a dataset about students and a dataset about teachers. Due to the organization of the university, suppose furthermore that these datasets are accessible, kept and/or maintained by different people. Alice, say, knows everything about students, when teachers have no secret for Bob. To start with our calculation of a student-teacher ratio, let's ask Alice to provide us with a usable dataset.

``` r
library(modulr)

# This module provides a dataset relating students and their inscriptions to courses.
# Alice is the maintainer of this module.
"data/students" %provides%
  function() {
    students <- data.frame(
      id = c(1, 2, 2, 3, 3, 3),
      course = c("maths", "maths", "physics", "maths", "physics", "chemistry"),
      stringsAsFactors = F)
    return(students)
  }
#> [2015-08-29 14:13:06.026829] defining [data/students] ...
```

The anatomy of this module is very simple: "data/student" is its name and the body of the function following the `%provides%` operator (which is part of a *syntactic sugar* for the more verbose function `define`) contains its core functionality, namely returning the required data frame.

It is important to note that no intrinsic computation took place in this **definition** process. The DI framework simply **registered** the module, relaying the actual evaluation of its body to another **instanciation** stage, as we'll see below.

In parallel, let's ask Bob to provide us with a similar module regarding the teachers.

``` r
# This module provides a dataset relating teachers and their courses.
# Bob is the maintainer of this module.
"data/teachers" %provides%
  function() {
    teachers <- data.frame(
      id = c(1, 2, 3),
      course = c("maths", "physics", "chemistry"),
      stringsAsFactors = F)
    return(teachers)
  }
#> [2015-08-29 14:13:06.032962] defining [data/teachers] ...
```

Now that we have these two modules at our disposal, let's combine them into another module that returns a student-teacher ratio.

``` r
"bad_stat/student_teacher_ratio" %requires%
  list(
    students = "data/students",
    teachers = "data/teachers"
  ) %provides%
  function(students, teachers) {
    ratio <- length(unique(students$id)) / length(unique(teachers$id))
    return(ratio)
  }
#> [2015-08-29 14:13:06.038770] defining [bad_stat/student_teacher_ratio] ...
```

The `%requires%` operator allows us to specify the modules we rely on for the calculation we provide. This list of **dependencies** assigns some arbitrary and ephemeral names to the required modules. These are those names that are then used to call objects into which the results of the required modules are **injected**, and available for use in the body of the module's definition.

It is now time to see the DI framework in action.

``` r
ratio %<=% "bad_stat/student_teacher_ratio"
#> [2015-08-29 14:13:06.043649] making [bad_stat/student_teacher_ratio] ...
#> [2015-08-29 14:13:06.044099] * checking definitions ...
#> [2015-08-29 14:13:06.056997] * found 2 dependencies(s) with 3 modules(s) on 2 layer(s)
#> [2015-08-29 14:13:06.058026] ** making [data/students] ...
#> [2015-08-29 14:13:06.059385] ** making [data/teachers] ...
#> [2015-08-29 14:13:06.060976] ** making [bad_stat/student_teacher_ratio] ...
```

We say that the `%<=%` operator **instanciates** the module given on its right-hand side. Obviously, there are three modules involved in this process, namely `[data/student]` and `[data/teachers]` which are independent on a first *layer*, and `[bad_stat/student_teacher_ration]` which depends on them on a second layer. Under the hood, the framework figures out the directed acyclic graph (DAG) of the dependencies and computes a topological sort, grouped by independent modules into layers. All the modules are then evaluated in order and the final result is assigned to the left-hand side of the `%<=%` operator.

``` r
print(ratio)
#> [1] 1
```

Code of Conduct
---------------

This project adheres to the [Open Code of Conduct](http://todogroup.org/opencodeofconduct/#modulr/alain.clement-pavon@unil.ch). By participating, you are expected to honor this code.
