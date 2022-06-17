print(getwd())

test_that("read plumbers works", {
  expect_error(
    read_plumbers(NULL),
    "`file` must be specified"
  )
  expect_error(
    read_plumbers("non_existfile.txt"),
    "`file` doesn't exist"
  )
  expect_true(
    inherits(read_plumbers("/home/hrychaniuk/projects/wrsa/test_service.yml"),
    "list")
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
      create_table_plumber(system.file("plumber_services.yaml",package="plumber.control")),
      "data.frame"
    )
  )

  expect_error(
    create_table_plumber(system.file("wrongfile2.yaml",package="plumber.control")),
    paste("You are not allowed to use another names than", paste0(getOption("allowed_names"),collapse = ","))
  )

  expect_error(
    create_table_plumber(system.file("wrongfile1.yaml",package="plumber.control")),
    "Yaml file must be non empty"
  )
})
