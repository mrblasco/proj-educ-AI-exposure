suppressPackageStartupMessages({
    require(dplyr)
    require(haven)
})

data_path <- file.path(
    "data-raw",
    "CEDEFOP ESJS2 Microdata_17_03_2023_v3.dta"
)

message("Processing data from: ", data_path)
raw_esjs <- haven::read_dta(data_path)

ds <- raw_esjs %>%
    mutate(
        across(everything(), as_factor)
    ) %>%
    select(
        sex = A_SEX,
        age = A_AGE,
        country = COUNTRYCODE,
        educ = E_HIGHEDL,
        age_degree = A_QEDU,
        field_b = E_FIELDB,
        field_n = E_FIELDN,
        isco_08_1d = A_QOCC,
        isco_08_title = B_ISCOD2,
        weight = Pan_Country_weight_v2,
    )

dplyr::glimpse(ds)

out_path <- file.path("data", "cedefop_esjs2_clean.rds")
saveRDS(ds, out_path)

message("✅ Saved cleaned esjs2 data to: ", out_path)