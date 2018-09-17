#!/bin/bash

pdflatex -shell-escape SR_MThesis_Emulation.tex
biber SR_MThesis_Emulation
pdflatex -shell-escape SR_MThesis_Emulation.tex
pdflatex -shell-escape SR_MThesis_Emulation.tex
