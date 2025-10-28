all: report.pdf view

# --- report 

report.pdf : report.Rmd refs.bib _output.yml analysis.R
	Rscript -e "rmarkdown::render(\
		input = '$<',\
		output_file = '$@',\
		output_format = 'bookdown::pdf_document2',\
		params = NULL\
	)"

# --- analysis

output/analysis.html : analysis.R
	mkdir output
	Rscript -e "rmarkdown::render('$<')"

# --- data 

import: scripts/01_import_data.R
	Rscript $<

view: 
	open -a Skim report.pdf
