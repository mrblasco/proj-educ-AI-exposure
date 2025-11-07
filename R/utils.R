shorten_field_b <- function(x) {
    case_when(
        grepl("Generic", x) ~ "Generic",
        grepl("Arts.*humanities", x) ~ "Arts & Humanities",
        grepl("Social sciences", x) ~ "Soc. Sci., Jour. & Inf.",
        grepl("Business", x) ~ "Business & Law",
        grepl("Natural sciences", x) ~ "Nat. Sci., Math & Stat",
        grepl("^Information", x) ~ "ICTs",
        grepl("Engineer", x) ~ "Eng., Manuf. & Const",
        grepl("Agriculture", x) ~ "Agri., For., Fish. & Vet",
        grepl("Services", x) ~ "Services",
        grepl("Health", x) ~ "Health and welfare",
        is.na(x) ~ "Unknown",
        TRUE ~ x
    )
}
