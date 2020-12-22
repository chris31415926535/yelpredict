model_coeff_tibble <- tibble::tribble(
~"qtile", ~"intercept", ~"afinn_mean", ~"buts_nots",
1,         -0.599,       1.20,          -1.03,
2,         -0.911,       1.36,          -0.671,
3,         -1.21,        1.58,          -0.477,
4,         -1.53,        1.85,          -0.337,
5,         -2.24,        2.37,          -0.145
)

#save(list = "model_coeff_tibble", file = "data/model_coeff_tibble.rda")
usethis::use_data_raw(name = "model_coeff_tibble")
