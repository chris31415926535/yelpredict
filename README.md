
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

Here’s a simple example that runs some test reviews through the model.
I’ve written three straightforward reviews, and then one tricky one
with lots of negations to try to fool the model.

``` r
library(yelpredict)
library(tibble)
library(magrittr)

review_examples <- tribble(
  ~"review_text", ~"star_rating",
  "This place was awful!", 1,
  "The service here was great I loved it it was amazing.", 5,
  "Meh, it was pretty good I guess but not the best.", 4,
  "Not bad, not bad at all, really the opposite of terrible. I liked it.", 5
)

review_examples %>%
  knitr::kable()
```

| review\_text                                                          | star\_rating |
| :-------------------------------------------------------------------- | -----------: |
| This place was awful\!                                                |            1 |
| The service here was great I loved it it was amazing.                 |            5 |
| Meh, it was pretty good I guess but not the best.                     |            4 |
| Not bad, not bad at all, really the opposite of terrible. I liked it. |            5 |

The first step is to “flatten” the true ratings down from integer star
ratings to binary positive/negative ratings. I’ve written a simple
function called `flatten_stars()` to take care of this: you pipe the
input data to it and tell it which column contains the numeric ratings,
and it does the rest.

``` r

review_examples %>%
  flatten_stars(star_rating) %>%
  knitr::kable()
```

| review\_text                                                          | rating |
| :-------------------------------------------------------------------- | :----- |
| This place was awful\!                                                | NEG    |
| The service here was great I loved it it was amazing.                 | POS    |
| Meh, it was pretty good I guess but not the best.                     | POS    |
| Not bad, not bad at all, really the opposite of terrible. I liked it. | POS    |

The next step is to *prepare* the text by finding its average AFINN
score, the number of buts/nots, and which word-length quintile it falls
into. The `prepare_yelp()` function takes care of this: you pipe the
data to it and specify the column containing the text.

``` r
review_examples %>%
  flatten_stars(star_rating) %>%
  prepare_yelp(review_text) %>%
  knitr::kable()
```

| review\_text                                                          | rating | afinn\_mean | buts\_nots | qtile |
| :-------------------------------------------------------------------- | :----- | ----------: | ---------: | ----: |
| This place was awful\!                                                | NEG    |  \-3.000000 |          0 |     1 |
| The service here was great I loved it it was amazing.                 | POS    |    3.333333 |          0 |     1 |
| Meh, it was pretty good I guess but not the best.                     | POS    |    2.333333 |          2 |     1 |
| Not bad, not bad at all, really the opposite of terrible. I liked it. | POS    |  \-1.750000 |          1 |     1 |

Next we invoke the model to get the probability that each review is
positive. We do this by piping our flattened and prepared data to
`get_prob()`, which has no mandatory arguments and returns a log-odds
and probability for each review.

``` r
review_examples %>%
  flatten_stars(star_rating) %>%
  prepare_yelp(review_text)%>%
  get_prob() %>%
  knitr::kable()
```

| review\_text                                                          | rating | afinn\_mean | buts\_nots | qtile | log\_odds |      prob |
| :-------------------------------------------------------------------- | :----- | ----------: | ---------: | ----: | --------: | --------: |
| This place was awful\!                                                | NEG    |  \-3.000000 |          0 |     1 |   \-4.199 | 0.0147886 |
| The service here was great I loved it it was amazing.                 | POS    |    3.333333 |          0 |     1 |     3.401 | 0.9677358 |
| Meh, it was pretty good I guess but not the best.                     | POS    |    2.333333 |          2 |     1 |     0.141 | 0.5351917 |
| Not bad, not bad at all, really the opposite of terrible. I liked it. | POS    |  \-1.750000 |          1 |     1 |   \-3.729 | 0.0234536 |

The last modeling step is to predict the rating, which we do with the
suitably named `predict_rating()` function. By default it predicts a
positive rating if the probability is \> 0.5, but this can be modified.
(Note that 0.5 gives the best results.)

``` r
review_examples %>%
  flatten_stars(star_rating) %>%
  prepare_yelp(review_text)%>%
  get_prob() %>%
  predict_rating() %>%
  knitr::kable()
```

| review\_text                                                          | rating | afinn\_mean | buts\_nots | qtile | log\_odds |      prob | pred |
| :-------------------------------------------------------------------- | :----- | ----------: | ---------: | ----: | --------: | --------: | :--- |
| This place was awful\!                                                | NEG    |  \-3.000000 |          0 |     1 |   \-4.199 | 0.0147886 | NEG  |
| The service here was great I loved it it was amazing.                 | POS    |    3.333333 |          0 |     1 |     3.401 | 0.9677358 | POS  |
| Meh, it was pretty good I guess but not the best.                     | POS    |    2.333333 |          2 |     1 |     0.141 | 0.5351917 | POS  |
| Not bad, not bad at all, really the opposite of terrible. I liked it. | POS    |  \-1.750000 |          1 |     1 |   \-3.729 | 0.0234536 | NEG  |

Finally, if so desired you can compute the overall accuracy with the
function `get_accuracy()`, which takes the name of the true ratings as
its input.

``` r
review_examples %>%
  flatten_stars(star_rating) %>%
  prepare_yelp(review_text)%>%
  get_prob() %>%
  predict_rating() %>%
  get_accuracy(rating) %>%
  knitr::kable()
```

| accuracy |
| -------: |
|     0.75 |

As expected, the model is 75% accurate on this toy set of data: it got
confused by the review with lots of negations.

## For more details

  - [This blog post](FIXME) has more details on the motivation,
    methodology, and empirical results.

  - I created this model as part of an MBA-level directed reading in
    natural language processing at the University of Ottawa’s Telfer
    School of Management. For anyone interested [my entire lab notebook
    is available here, warts and
    all](https://chris31415926535.github.io/mba6292/).
