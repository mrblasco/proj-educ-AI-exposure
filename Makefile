all:

report: 
	bash scripts/render_report.sh

import: scripts/01_import_data.R
	Rscript $<

view: 
	open -a Skim _output/main.pdf
