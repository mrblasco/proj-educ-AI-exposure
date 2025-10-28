path <- file.path("data-raw/ISCO-08 EN Structure and definitions.xlsx")
dat <- readxl::read_xlsx(path)



dat <- dplyr::select(
    dat,
    job_level = `Level`,
    job_id = `ISCO 08 Code`,
    job_title = `Title EN`,
)

dat <- dplyr::distinct(dat)
str(dat)


out_path <- file.path("data", "ilo_isco_clean.rds")
saveRDS(dat, out_path)
message("✅ Saved cleaned ilo data to: ", out_path)