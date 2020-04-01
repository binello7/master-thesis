#!/bin/bash
filename="Abstract_SRusca"

pdflatex="pdflatex $filename.tex"
bibtex="bibtex $filename"

eval $pdflatex
eval $bibtex
eval $pdflatex
eval $pdflatex

rm $filename.{aux,bbl,blg,log,out}
