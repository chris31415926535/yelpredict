#library(tibble)

test <- tibble::tibble(text = c("I am happy.", "I AM SO SAD but it could be worse!"),
                       rating = c("POS", "NEG"))

testthat::test_that("Function prepare_yelp() is giving the right AFINN, but/not, and word quintiles.", {
  testthat::expect_equal( prepare_yelp(test, text) %>% dplyr::pull(afinn_mean),
                          c(3, -2.5))
  testthat::expect_equal( prepare_yelp(test, text) %>% dplyr::pull(buts_nots),
                          c(0, 1))
  testthat::expect_equal( prepare_yelp(test, text) %>% dplyr::pull(qtile),
                          c(1, 1))
})

testthat::test_that("Function get_prob() is working properly.", {
  testthat::expect_equal( prepare_yelp(test, text) %>%
                            get_prob() %>%
                            dplyr::pull(prob),
                          c(0.952619283, 0.009670095))
})

testthat::test_that("Function predict_rating() is working properly.", {
  testthat::expect_equal(
    test %>%
    prepare_yelp(text) %>%
    get_prob() %>%
    predict_rating() %>%
    dplyr::pull(pred),
    c("POS", "NEG")
  )
})

testthat::test_that("Function get_accuracy() is working properly.", {
  testthat::expect_equal(
    test %>%
      prepare_yelp(text) %>%
      get_prob() %>%
      predict_rating() %>%
      get_accuracy(rating) %>%
      as.numeric(),
    1
  )
})


