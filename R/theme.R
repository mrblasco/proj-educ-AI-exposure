require(ggplot2)

theme_set(theme_minimal(base_size = 13, base_family = "Helvetica"))
theme_update(
    plot.title.position = "plot",
    plot.caption = element_text(size = 9, hjust = 1, color = "grey40"),
    panel.grid.major.y = element_line(linetype = 3),
    panel.grid.minor = element_blank(),
    axis.text.y = element_text(size = 10),
    axis.title = element_blank(),
    plot.margin = margin(1, 1, 1, 1, unit = "lines"),
    legend.position = "none"
)