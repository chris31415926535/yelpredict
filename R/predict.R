globalVariables(c("%>%", "model_coeff_tibble", ".", "afinn_mean" , "buts_nots" , "correct" ,"log_odds" , "pred" , "prob" , "qtile" , "rating_factor" , "rowid" , "value" , "word" , "words"))
#' Get the probability a Yelp review is positive.
#'
#' @param data A tibble of Yelp reviews pre-processed with `prepare_yelp()` that
#'   has a column for mean AFINN score, the number of buts/nots, and each
#'   review's word-length quintile.
#' @param model_coefs An optional tibble containing different model parameters.
#'
#' @return The original data with new columns for the log-odds and probability
#'   that each review is positive.
#' @export
get_prob <- function (data, model_coefs = model_coeff_tibble){

  results <- data %>%
    dplyr::mutate(log_odds = model_coefs$intercept[qtile] + model_coefs$afinn_mean[qtile] * afinn_mean + model_coefs$buts_nots[qtile] * buts_nots,
           prob = 1 / (1 + exp(-log_odds)))

  return(results)
}

#' Predict whether a Yelp review is positive or negative.
#'
#' @param data A tibble of Yelp reviews pre-processed with `prepare_yelp()` and
#'   scored with `get_prob()`.
#' @param threshold An optional threshold. Default is 0.5 which provided the
#'   best accuracy in testing.
#'
#' @return The input data with a new column containing a predicted rating of
#'   "POS" or "NEG" for each review.
#' @export
predict_rating <- function(data, threshold = 0.5){
  data %>%
    dplyr::mutate(pred = dplyr::if_else(prob > threshold, "POS", "NEG")) %>%
    return()

}

#' Get the accuracy of a set of Yelp review rating predictions.
#'
#' @param data A tibble of Yelp reviews that has been pre-processed with
#'   `prepare_yelp()`, scored with `get_prob()`, and had a prediction made with
#'   `predict_rating()`.
#' @param var The column containing true ratings.
#' @return A one-value tibble with the total prediction accuracy.
#' @export
get_accuracy <- function(data, var) {
  data %>%
    dplyr::transmute(correct = (pred == {{var}})) %>%
    dplyr::summarise(accuracy = mean(correct)) %>%
    return()
}


#' Prepare text for predictive modeling
#'
#' Function to take a tibble with a text column of Yelp reviews and return an
#' augmented tibble with each review's mean AFINN score, number of "buts/nots",
#' and word-length quintile.
#'
#' @param data A tibble containing a column of plaintext Yelp reviews.
#' @param var A column containing plaintext Yelp reviews.
#' @param qtiles An optional vector of 5 integers with the left-hand boundaries
#'   of word-length quintiles. The fifth quintile's upper bound is assumed to be
#'   infinite.
#'
#' @return The input data plus columns for mean AFINN score, number of "buts/nots",
#' and word-length quintile.
#' @export
prepare_yelp <- function(data, var, qtiles = c(1, 39, 65, 102, 169, 1033 )) {

  # get the text columns in a one-column tibble
  input_data <- data %>% dplyr::select ({{var}})

  results <- input_data %>%
    dplyr::mutate(rowid = 1:nrow(.)) %>%
    tidytext::unnest_tokens(output = word, input = {{var}}) %>%
    dplyr::left_join(tidytext::get_sentiments(lexicon = "afinn"), by="word") %>%
    dplyr::group_by(rowid) %>%
    dplyr::summarise(afinn_mean = mean(value, na.rm = T)) %>%
    dplyr::mutate(afinn_mean = dplyr::if_else(is.na(afinn_mean) | is.nan(afinn_mean), 0, afinn_mean)) %>%
    dplyr::bind_cols(input_data) %>%
    dplyr::mutate(buts_nots = stringr::str_count({{var}}, "but ") + stringr::str_count({{var}}, "not ")) %>%
    dplyr::mutate(words = stringr::str_count({{var}}, " ") + 1) %>%
    dplyr::mutate(qtile = dplyr::case_when(
      words %in% qtiles[1]:qtiles[2] ~ 1,
      words %in% qtiles[2]:qtiles[3] ~ 2,
      words %in% qtiles[3]:qtiles[4] ~ 3,
      words %in% qtiles[4]:qtiles[5] ~ 4,
      words > qtiles[5] ~ 5)) %>%
    dplyr::select(-rowid, -words, -{{var}})


  return(dplyr::bind_cols(data, results))
}

# <- NULL
