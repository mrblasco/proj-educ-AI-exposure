# ----- setup, include = FALSE
library(dplyr)
library(knitr)
library(eurostat)

opts_chunk$set(error = TRUE)

# ---- search

#d <- get_eurostat("educ_uoe_enrt03", cache_dir = "data-raw")
d <- readRDS("data-raw/educ_uoe_enrt03.rds")

# ---- 

d <- d %>% 
    filter(
        sex == "T",
        geo == "DE",
        isced11 == "ED5-8",
        iscedf13 != "UNK"
    )

head(d)

# ----- fig.width = 9, fig.asp = 1
library(ggplot2)
library(ggrepel)

d %>%
    filter(
        nchar(iscedf13) == 4, 
        !grepl("0$", iscedf13), # residual category
        TIME_PERIOD > "2019-01-01"
    ) %>% 
    mutate(
        values = 100 * values / values[TIME_PERIOD == "2020-01-01"], 
        .by = iscedf13
    ) %>%
    mutate(group = substr(iscedf13, 1, 3)) %>% 
    ggplot(
        aes(
            x = TIME_PERIOD,
            y = values,
            group = iscedf13,
            color = iscedf13
        )
    ) + 
    geom_hline(yintercept = 100, linewidth = 1.5) +
    scale_y_log10() +
    facet_wrap(~group, scales = "free") +
    coord_cartesian(clip = "off") +
    geom_line() +
    geom_point() +
    geom_text(
        data = . %>%
            group_by(iscedf13) %>% 
            filter(TIME_PERIOD %in% max(TIME_PERIOD)),
        aes(label = iscedf13),
        direction = "y",
        hjust = -0.01, vjust = -0.5
    ) +
    theme_minimal() +
    theme(
        legend.position = "none",
        plot.margin = margin(1, 10, 1, 1, "lines"),
    ) 
