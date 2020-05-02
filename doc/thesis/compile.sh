#!/bin/bash

filename="SR_MThesis_Emulation"

pdflatex -shell-escape $filename.tex
biber $filename
pdflatex -shell-escape $filename.tex
pdflatex -shell-escape $filename.tex

rm -r _minted-*
rm Appendices/Appendix.aux
rm Chapters/*.aux
rm $filename.{aux,bbl,bcf,blg,log,out,run.xml,toc}
