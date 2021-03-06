% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/predict.R
\name{prepare_yelp}
\alias{prepare_yelp}
\title{Prepare text for predictive modeling}
\usage{
prepare_yelp(data, var, qtiles = c(1, 39, 65, 102, 169, 1033))
}
\arguments{
\item{data}{A tibble containing a column of plaintext Yelp reviews.}

\item{var}{A column containing plaintext Yelp reviews.}

\item{qtiles}{An optional vector of 5 integers with the left-hand boundaries
of word-length quintiles. The fifth quintile's upper bound is assumed to be
infinite.}
}
\value{
The input data plus columns for mean AFINN score, number of "buts/nots",
and word-length quintile.
}
\description{
Function to take a tibble with a text column of Yelp reviews and return an
augmented tibble with each review's mean AFINN score, number of "buts/nots",
and word-length quintile.
}
