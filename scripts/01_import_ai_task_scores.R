dir.create("data", showWarnings = FALSE)

ai_path <- file.path(
    "data-raw",
    "Final_Scores_ISCO08_Gmyrek_et_al_2025.xlsx"
)

raw_scores <- readxl::read_xlsx(ai_path, sheet = 1)

scores <- dplyr::select(
    raw_scores,
    isco_08_4d        = ISCO_08,
    task_id           = taskID,
    task_description  = Task_ISCO,
    score_2025        = score_2025
)


out_path <- file.path("data", "scores_clean_2025.rds")
saveRDS(scores, out_path)

message("✅ Saved cleaned scores to: ", out_path)