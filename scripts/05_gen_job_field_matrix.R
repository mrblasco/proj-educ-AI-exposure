suppressPackageStartupMessages({
    require(nnet)
    require(dplyr)
    require(broom)
})

df <- readRDS(
    file.path("data", "cedefop_esjs2_clean.rds")
)
glimpse(df)

fit <- multinom(isco_08_1d ~ field_b, data = df)

new_df <- distinct(df, field_b)
mat <- predict(fit, new_df, type = "probs")

# save
filename <- sprintf(
    "matrix_fieldb_job1d_%sx%s.rds", 
    nrow(mat), ncol(mat)
)
out_path <- file.path("data", filename)
saveRDS(mat, out_path)
message("✅ Saved matrix data to: ", out_path)