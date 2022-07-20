
test_that("read plumbers works", {
  expect_error(
    read_plumbers(NULL),
    "`file` must be specified"
  )
  expect_error(
    read_plumbers("non_existfile.txt"),
    "`file` doesn't exist"
  )
})

test_that("create plumber table", {
  expect_error(
    create_table_plumber(NULL),
    "`file` must be specified"
  )
  expect_error(
    create_table_plumber("non_existfile.txt"),
    "`file` doesn't exist"
  )

  expect_true(
    inherits(
      create_table_plumber(system.file("plumber_services.yaml", package="R.control")),
      "data.frame"
    )
  )

  expect_error(
    create_table_plumber(system.file("wrongfile2.yaml",package="R.control")),
    paste("You are not allowed to use another names than",
          paste0(getOption("allowed_names"),collapse = ","))
  )

  expect_error(
    create_table_plumber(system.file("wrongfile1.yaml",package="R.control")),
    "Yaml file must be non empty"
  )
})
