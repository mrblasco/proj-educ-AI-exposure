suppressPackageStartupMessages({
    library(dplyr)
    library(readxl)
    library(haven)
    library(knitr)
})

dir.create("data", showWarnings = FALSE)

# ------------------
# 1. Import AI Task Scores
# ------------------

ai_path <- file.path(
    "data-raw",
    "Final_Scores_ISCO08_Gmyrek_et_al_2025.xlsx"
)

raw_scores <- readxl::read_xlsx(ai_path, sheet = 1)
message("==> Reading AI task scores from: ", ai_path)

scores <- raw_scores %>% 
    select(
        score_2025        = score_2025,
        job_task      = taskID,
        job_id       = ISCO_08,
    ) %>%
    mutate(
        job_level = nchar(job_id)
    )

scores_out <- file.path("data", "scores_clean_2025.rds")
saveRDS(scores, scores_out)
message("✅ Saved cleaned AI scores to: ", scores_out)

# ------------------
# 2. Import ISCO Codes
# ------------------

isco_path <- file.path(
    "data-raw",
    "ISCO-08 EN Structure and definitions.xlsx"
)

raw_isco <- read_xlsx(isco_path, sheet = 1)
message("==> Reading ISCO defs from: ", isco_path)

job_defs <- raw_isco %>%
    select(
        job_id = `ISCO 08 Code`,
        job_level = `Level`,
        job_title = `Title EN`,
    ) %>%
    distinct()

isco_out <- file.path("data", "ilo_isco_clean.rds")
saveRDS(job_defs, isco_out)
message("✅ Saved cleaned ilo data to: ", isco_out)

# ------------------
# 3. Import CEDEFOP ESJS2 Survey
# ------------------
data_path <- file.path("data-raw", "CEDEFOP ESJS2 Microdata_17_03_2023_v3.dta")
message("==> Reading survey data from: ", data_path)

raw_esjs <- read_dta(data_path)

job_survey <- raw_esjs %>%
    mutate(across(everything(), as_factor)) %>%
    select(
        sex = A_SEX,
        age = A_AGE,
        country = COUNTRYCODE,
        educ = E_HIGHEDL,
        age_degree = A_QEDU,
        field_b = E_FIELDB,
        field_n = E_FIELDN,
        job_title = B_ISCOD2,
        pay = F_PAYBANDALL,
        displace = F_DISPLJOB,
        weight = Pan_Country_weight_v2
    ) %>%
    mutate(
        job_level = "2",
        age_degree = as.numeric(as.character(age_degree)),
        age = as.numeric(as.character(age)),
        weight = as.numeric(weight),
    )

# Clean job titles
normalize_job_title <- function(x) {
    tolower(x) %>%
        gsub("wood.?working", "woodworking", .) %>% 
        gsub("electronics trades", "electronic trades", .) %>% 
        gsub("speciali[zs]ed", "specialised", .) %>% 
        gsub(", excluding electricians", " (excluding electricians)", .)
}

job_survey <- job_survey %>%
    mutate(
        job_title_clean = normalize_job_title(job_title),
    )

job_defs <- mutate(
    job_defs,
    job_title_clean = normalize_job_title(job_title),
)

job_survey <- job_survey %>%
    left_join(
        job_defs, by = c("job_title_clean", "job_level"),
        suffix = c("_esjs2", "_ilo")
    )

job_survey <- job_survey %>%
    rename(
        job_title = job_title_ilo
    )


survey_out <- file.path("data", "skills_survey_clean.rds")
saveRDS(job_survey, survey_out)
message("✅ Saved cleaned ESJS2 survey data to: ", survey_out)