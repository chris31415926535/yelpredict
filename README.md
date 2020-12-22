
<!-- README.md is generated from README.Rmd. Please edit that file -->

# yelpredict

<!-- badges: start -->

<!-- badges: end -->

The goal of yelpredict is to provide a fast and accurate classification
model that prdicts a Yelp review’s rating based on its text. The package
follows tidy principles and works with the pipe operator. The code is
vectorized so can process thousands of reviews in seconds, and it was
approximately 84.5% accurate on a balanced dataset of over 200,000 Yelp
reviews.

## Installation

You can install the released version of yelpredict from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("yelpredict")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("chris31415926535/yelpredict")
```

## Example

This is a basic example that shows how to apply the model to three short
sample interviews:

``` r
library(yelpredict)
library(tibble)

review_examples <- tribble(
  ~"review_text", ~"true_rating",
  "This place was awful!", "NEG",
  "The service here was great I loved it it was amazing.", "POS",
  "Meh, it was pretty good I guess but not the best.", "POS"
)

review_examples %>%
  prepare_yelp(review_text) %>%
  get_prob() %>%
  predict_rating() %>%
  knitr::kable()
```

| review\_text                                          | true\_rating | afinn\_mean | buts\_nots | qtile | log\_odds |      prob | pred |
| :---------------------------------------------------- | :----------- | ----------: | ---------: | ----: | --------: | --------: | :--- |
| This place was awful\!                                | NEG          |  \-3.000000 |          0 |     1 |   \-4.199 | 0.0147886 | NEG  |
| The service here was great I loved it it was amazing. | POS          |    3.333333 |          0 |     1 |     3.401 | 0.9677358 | POS  |
| Meh, it was pretty good I guess but not the best.     | POS          |    2.333333 |          2 |     1 |     0.141 | 0.5351917 | POS  |

If you have the true review ratings, the package provides the function
`get_accuray()` as a convenience wrapper to `summarise()` that accepts
the name of the true-rating column.

``` r
review_examples %>%
  prepare_yelp(review_text) %>%
  get_prob() %>%
  predict_rating() %>%
  get_accuracy(true_rating) %>%
  knitr::kable()
```

| accuracy |
| -------: |
|        1 |

## For more details

  - [This blog post](FIXME) has more details on the motivation,
    methodology, and empirical results.

  - I created this model as part of an MBA-level directed reading in
    natural language processing at the University of Ottawa’s Telfer
    School of Management. For anyone interested [my entire lab notebook
    is available here, warts and
    all](https://chris31415926535.github.io/mba6292/).