# ---- setup, include = FALSE
library(here)
library(dplyr)
library(knitr)
library(tidyr)
library(stringr)
library(broom)
library(ggplot2)
library(eurostat)
library(sf)
library(countrycode)
library(openxlsx)

debug <- TRUE
opts_chunk$set(
    error = debug,
    echo = FALSE,
    message = FALSE,
    warning = FALSE,
    comment = ""
)

src_caption <- "Source: ESJS2 dataset and Gmyrek et al. 2025"

source("R/theme.R")
source("R/utils.R")



# ---- data, include = FALSE ----------------------------------------

job_ai <- readRDS("data/scores_clean_2025.rds")

job_ai <- job_ai %>%
    mutate(
        job_id = substr(job_id, 1, 2),
        job_level = nchar(job_id)
    )

job_survey <- readRDS("data/skills_survey_clean.rds")

job_survey <- job_survey %>%
    mutate(
        weight = as.numeric(as.character(weight)),
        educ_1d = case_when(
            grepl("[5678]", educ) ~ "High (ISCED 5-8)",
            TRUE ~ "Other"
        )
    )

job_survey <- job_survey %>%
    filter(!is.na(job_title))

job_survey <- job_survey %>%
    filter(!field_n %in% c("No answer", "Don't know"))

job_counts <- job_survey %>%
    count(job_id, field_b, field_n, country, sex, wt = weight)

job_counts <- job_counts %>% 
    filter(!job_id %in% c("01", "02", "03"))

# ---- descriptives ----------------------------------------

kable(head(job_survey), caption = "Survey")
kable(head(job_counts))

# ---- regression ----------------------------------------

fit_score <- lm(score_2025 ~ job_id, job_ai)

job_counts$predicted_score <- predict(fit_score, job_counts)

# ---- aggregate data ----------------------------------------

eu27_codes <- c("AT","BE","BG","HR","CY","CZ","DK","EE","FI","FR",
                "DE","GR","HU","IE","IT","LV","LT","LU","MT","NL",
                "PL","PT","RO","SK","SI","ES","SE")

eu27 <- countrycode(eu27_codes, origin = "iso2c", "country.name")

job_counts_eu27 <- job_counts %>%
    filter(country %in% eu27) %>%
    mutate(country = "EU27")

job_counts <- job_counts %>%
    bind_rows(job_counts_eu27) %>%
    mutate(weight = n / sum(n), .by = c(country, sex))

df_field <- job_counts %>%
    summarise(
        mean_pred_score = weighted.mean(predicted_score, weight),
        .by = c(country, field_b, field_n)
    ) %>%
    mutate(
        zscore = scale(mean_pred_score),
        .by = country
    )

df_sex <- job_counts %>%
    dplyr::filter(
        sex %in% c("Male", "Female"),
        country == "EU27",
    ) %>%
    summarise(
        mean_predicted_score = weighted.mean(
            predicted_score, weight
        ),
        .by = c(field_n, sex)
    ) %>%
    mutate(
        zscore = scale(mean_predicted_score),
        .by = sex
    )

tbl_field <- df_field %>%
    filter(!is.na(field_n), !is.na(zscore)) %>%
    arrange(country) %>%
    mutate(zscore = round(zscore, 2)) %>%
    select(Field = field_n, country, zscore) %>%
    pivot_wider(
        names_from = country,
        values_from = zscore,
    )


tbl_sex <- df_sex %>% 
    mutate(zscore = round(zscore, 2)) %>%
    select(Field = field_n, sex, zscore) %>%
    pivot_wider(
        names_from = sex,
        values_from = zscore,
    )


# ---- viz-field, fig.asp = 1 ----------------------------------------

df_field_eu27 <- df_field %>%
    filter(!is.na(field_n), country == "EU27")

plot_field <- df_field_eu27 %>%
    ggplot(
        aes(
            x = reorder(field_n, zscore),
            y = zscore,
            fill = zscore
        )
    ) +
    geom_col(width = 0.7) +
    coord_flip() +
    scale_fill_gradient2(
        low = "#4575b4", mid = "grey90", high = "#d73027",
        midpoint = 0,
        name = "Z-score"
    ) +
    geom_text(
        aes(label = sprintf("%.2f", zscore)),
        hjust = ifelse(df_field_eu27$zscore > 0, -0.1, 1.1),
        color = "black",
        size = 3
    ) +
    labs(
        title = "Mean Predicted AI Exposure by Field",
        subtitle = "Z-scores centered at 0",
        caption = src_caption,
    ) +
    theme(
        plot.title.position = "plot",
        panel.grid.major.y = element_line(linetype = 3),
        panel.grid.minor = element_blank(),
        axis.text.y = element_text(size = 10),
        legend.position = "none"
    ) +
    ylim(min(df_field_eu27$zscore) - 0.3, max(df_field_eu27$zscore) + 0.3)

print(plot_field)

# ---- viz-sex, fig.asp = 1 ----------------------------------------

plot_sex <- df_sex %>%
    mutate(
        zscore_diff = zscore[sex == "Female"] - zscore[sex == "Male"],
        .by = field_n
    ) %>%
    na.omit() %>%
    ggplot(
        aes(
            x = zscore,
            y = reorder(field_n, zscore_diff),
            fill = sex,
            shape = sex,
            color = zscore_diff,
            group = reorder(field_n, zscore_diff),
        )
    ) +
    scale_fill_brewer(palette = "Set1") +
    scale_color_gradient2(
        low = "#4575b4", mid = "grey90", high = "#d73027",
        midpoint = 0,
        name = "Sex Diff."
    ) +
    ggplot2::coord_cartesian(clip = "off") +
    scale_shape_manual(values = c(21, 22)) +
    geom_line(linewidth = 2, alpha = 0.5) +
    geom_point(size = 3, color = "gray80") + 
    theme(legend.position = "bottom") + 
    labs(
        caption = src_caption,
    )

print(plot_sex)

plot_sex_bars <- df_sex %>%
    ggplot(
        aes(
            x = reorder(field_n, zscore),
            y = zscore,
            fill = zscore
        )
    ) +
    facet_grid(~sex) +
    geom_col(width = 0.7) +
    coord_flip() +
    scale_fill_gradient2(
        low = "#4575b4", mid = "grey90", high = "#d73027",
        midpoint = 0,
        name = "Z-score"
    ) +
    geom_text(
        aes(label = sprintf("%.2f", zscore)),
        hjust = ifelse(df_sex$zscore > 0, -0.1, 1.1),
        color = "black",
        size = 3
    ) +
    labs(
        title = "Mean Predicted AI Exposure by Field",
        subtitle = "Z-scores centered at 0",
        caption = src_caption,
    ) +
    ylim(min(df_sex$zscore) - 0.3, max(df_sex$zscore) + 0.3)

print(plot_sex_bars)

# ----- maps, fig.asp = 1.5, fig.width = 9 ----------------------------------------

df_field_b <- job_counts %>%
    mutate(weight = n / sum(n), .by = c(country, sex)) %>%
    summarise(
        mean_pred_score = weighted.mean(predicted_score, weight, na.rm = TRUE),
        .by = c(country, field_b)
    ) %>%
    mutate(
        zscore = scale(mean_pred_score),
        .by = country
    ) %>%
    mutate(
        mean_zscore_field = mean(zscore, na.rm = TRUE),
        .by = field_b
    )

tbl_country <- df_field_b %>%
    filter(!is.na(zscore), !is.na(field_b)) %>%
    mutate(
        zscore = round(zscore, 2), 
        country = countrycode(country, "country.name", "eurostat"),
    ) %>%
    arrange(country) %>%
    select(country, zscore, Field = field_b) %>%
    pivot_wider(
        names_from = country,
        values_from = zscore
    )


eu_map <- get_eurostat_geospatial(
    output_class = "sf",
    resolution = "20",
    nuts_level = 0
)

map_data <- eu_map %>%
    mutate(
        country = countrycode(CNTR_CODE, "eurostat", "country.name")
    ) %>%
    left_join(df_field_b, by = "country")

plot_map <- map_data %>%
    mutate(field_b_short = shorten_field_b(field_b)) %>%
    ggplot() +
    facet_wrap(~reorder(field_b_short, -mean_zscore_field)) +
    geom_sf(
        aes(fill = zscore),
        color = "grey95",
        size = 0.15
    ) +
    scale_fill_viridis_c(
        option = "magma", 
        na.value = "grey95", 
        name = "AI exposure",
        limits = c(-3, 3),
        breaks = seq(-3, 3, 1),
        labels = scales::number_format(accuracy = 0.1)
    ) +
    labs(
        title = "Predicted Mean Score by Country (High Education Level)",
        subtitle = "Eurostat NUTS 0 regions",
        caption = src_caption
    ) +
    coord_sf(
        xlim = c(-10, 35), 
        ylim = c(34, 72), 
        expand = FALSE
    ) +
    theme_minimal(base_family = "Helvetica") +
    theme(
        plot.margin = margin(10, 10, 10, 10),
        plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
        plot.subtitle = element_text(size = 12, hjust = 0.5, margin = margin(b = 8)),
        plot.caption = element_text(size = 9, hjust = 1, color = "grey40"),
        legend.position = "bottom",
        legend.key.width = unit(2, "cm"),
        legend.title = element_text(size = 10, face = "bold"),
        legend.text = element_text(size = 9),
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        strip.text = element_text(face = "bold"),
        panel.grid = element_blank(),
        panel.background = element_rect(fill = "white", color = NA)
    )

print(plot_map)


# ---- Info, include = !debug ----------------------------------------

sessionInfo()


# ---- Export tbl ----------------------------------------

try({
    wb <- createWorkbook()
    tbl_names <- ls(pattern = "^tbl_")
    tbl_list <- mget(ls(pattern = "^tbl_"), .GlobalEnv)
    for (nm in names(tbl_list)) {
        addWorksheet(wb, nm)
        writeData(wb, nm, tbl_list[[nm]])
    }
    saveWorkbook(wb, "tbl_export.xlsx", overwrite = TRUE)
})
