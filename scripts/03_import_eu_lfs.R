

data_path <- file.path(
    "data-raw", 
    "20251014_R24101_2_20251014_142212_JRC_S1_Y.csv"
)

dat <- read.table(
    data_path, sep = "\t",
    skip = 1, header = TRUE
)



dat_filtered <- dplyr::filter(
    dat,
    #COUNTRY == "EU27_2020",
    HATFIELD != "_Total",
    HATLEV1D == "High (ISCED 5-8)",
    !ISCO08_2D %in% c("_Total", "Not applicable", "Not stated")
)


dat_renamed <- dplyr::select(
    dat_filtered,
    country = COUNTRY,
    year = YEAR,
    sex = SEX,
    isco_08_2d = ISCO08_2D,
    field = HATFIELD,
    educ_1d = HATLEV1D,
    pop_ths = THS_POP,
    flags = OBS_STATUS
)


out_path <- file.path("data", "eu_lfs_clean.rds")
saveRDS(dat_renamed, out_path)

message("✅ Saved cleaned employment data to: ", out_path)