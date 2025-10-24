# ---- setup, include = FALSE
library(here)
library(dplyr)
library(knitr)
library(tidyr)
library(broom)
library(ggplot2)
library(nnet)

dir.create("figures")

debug <- TRUE
opts_chunk$set(
    error = debug,
    echo = debug,
    message = debug,
    warning = debug,
    comment = ""
)

# ---- utils, include = FALSE

extract_coef <- function(object) {
    broom::tidy(object, conf.int = TRUE) %>%
        dplyr::mutate(
            cis = sprintf(
                "[%.2f, %.2f]",
                .data[["conf.low"]],
                .data[["conf.high"]]
            ),
        )
}

shorten_fields <- function(x) {
    dplyr::case_when(
        grepl("00", x) ~ "Generic",
        grepl("01", x) ~ "Education",
        grepl("02", x) ~ "Arts & Hum",
        grepl("03", x) ~ "Social sci",
        grepl("04", x) ~ "Business & Law",
        grepl("05", x) ~ "Science & Math",
        grepl("06", x) ~ "ICT",
        grepl("07", x) ~ "Engineering",
        grepl("08", x) ~ "Agriculture",
        grepl("09", x) ~ "Health",
        grepl("10", x) ~ "Services",
        TRUE ~ x
    )
}


# ----- loda data, include = FALSE

scores <- readRDS(
    file.path("..", "data", "scores_clean_2025.rds")
)

employment <- readRDS(
    file.path("..", "data", "cedefop_esjs2_clean.rds")
)

eu_lfs <- readRDS(
    file.path("..", "data", "eu_lfs_clean.rds")
)


# ----- process data, include = FALSE

scores <- mutate(scores, isco_08_2d = substr(isco_08_4d, 1, 2))

employment <- employment %>% 
    mutate(
        educ_1d = case_when(
            grepl("[5678]", educ) ~ "High (ISCED 5-8)",
            TRUE ~ educ
        )
    ) %>% 
    filter(
        educ_1d == "High (ISCED 5-8)"
    )


# ---- descriptives

glimpse(employment)


# ---- multinom, cache = TRUE

model <- as.character(isco_08_title) ~ field_b

fit <- multinom(
    formula = model,
    data = employment,
    trace = FALSE
)

# ---- predictions


new_df <- count(employment, field_b)

pred <- cbind(
    new_df,
    predict(fit, type = "prob", new_df) * 100
)

# TODO: save matrix of predictions to files (probably turn into a script and save to data)
kable(head(pred), digits = 2)


# ---- Info, include = !debug

sessionInfo()