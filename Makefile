all: view

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

import: scripts/01_import_data.R
	Rscript $<

view: report.pdf
	open -a Skim $<
