#!/bin/bash

pdflatex -shell-escape SR_MThesis_Emulation.tex
biber main
pdflatex -shell-escape SR_MThesis_Emulation.tex
pdflatex -shell-escape SR_MThesis_Emulation.tex
