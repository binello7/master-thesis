#!/bin/bash

filename="03_Presentation"

pdflatex -shell-escape $filename.tex
rm -r _minted-*
rm $filename.{aux,bcf,log,nav,out,run.xml,snm,toc}

pdflatex Short_Abstract.tex
rm Short_Abstract.{aux,log}
