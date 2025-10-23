all: rds


# --- report 

report.pdf : report.Rmd refs.bib _output.yml
	Rscript -e "rmarkdown::render(\
		input = '$<',\
		output_file = '$@',\
		output_format = 'bookdown::pdf_document2',\
		params = NULL\
	)"

# --- analysis

analysis/analysis.html : analysis/analysis.R
	Rscript -e "rmarkdown::render('$<')"

# --- data 

rds: data/scores_clean_2025.rds data/cedefop_esjs2_clean.rds data/eu_lfs_clean.rds

data/scores_clean_2025.rds : scripts/01_import_ai_task_scores.R
	Rscript $<

data/cedefop_esjs2_clean.rds : scripts/04_import_cedefop_esjs2.R
	Rscript $<

data/eu_lfs_clean.rds : scripts/03_import_eu_lfs.R
	Rscript $<

view:
	open -a Skim report.pdf
