suppressPackageStartupMessages({
    require(nnet)
    require(dplyr)
    require(broom)
    require(knitr)
})

# load data
scores <- readRDS(
    file.path("data", "scores_clean_2025.rds")
)
scores <- mutate(scores, isco_08_2d = substr(isco_08_4d, 1, 2))
scores <- mutate(scores, isco_08_1d = substr(isco_08_4d, 1, 1))
glimpse(scores)


fit <- lm(score_2025 ~ isco_08_2d, data = scores)
coeffs <- tidy(fit, conf.int = TRUE)

# ---- Save
filename <- sprintf("coeffs_2d_%sx%s.rds", nrow(coeffs), ncol(coeffs))
out_path <- file.path("data", filename)
saveRDS(coeffs, out_path)
message("✅ Saved coeffs data to: ", out_path)

# ---- 1 d
fit <- lm(score_2025 ~ isco_08_1d, data = scores)
coeffs <- tidy(fit, conf.int = TRUE)

filename <- sprintf("coeffs_1d_%sx%s.rds", nrow(coeffs), ncol(coeffs))
out_path <- file.path("data", filename)
saveRDS(coeffs, out_path)
message("✅ Saved coeffs data to: ", out_path)
