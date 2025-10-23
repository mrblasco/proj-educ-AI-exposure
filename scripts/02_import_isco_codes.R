isco_path <- file.path(
    "../data-raw",
    "ISCO-08 EN Structure and definitions.xlsx"
)

isco <- readxl::read_xlsx(isco_path, sheet = 1)

codes <- select(
    filter(isco, Level == 2),
    ISCO08_2D = `ISCO 08 Code`,
    ISCO08_title  = `Title EN`
)

kable(
    head(codes), 
    caption = "ISCO table from ILO - Top rows (ILOSTAT)"
)
# https://ilostat.ilo.org/methods/concepts-and-definitions/classification-occupation/

