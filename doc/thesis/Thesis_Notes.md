# Thesis - Notes

## To check before hand-in:
# VERY IMPORTANT
* _MAKE SPELL CHECK!!_
* make titles active!!
* check all "Fig."
* check all "Tab."
* check all "Eq."
* check all "Sec."
* check all ??
* check all "Appendix"
* check active titles
* check for "GNU Octave"
* check use of "," and ";"
* change all / in units to [] (tables and plots)
* Separate results and discussion in CS1
* check "bla bla license"
* check missing references!!
* Q_!, Q_thresh, Q_thold?? which one??

# Less important
* review first sentence of paragraphs to highlight the whole paragraph
* either use numerical experiment or explain in intro what we mean with
  experiment
* remove adverbs like "it can IMMEDIATELY be observed"
* general discussion: answer kind of questions i had to answer after the
  presentation
* have a look at Rasmussen p. 27-28


    - "use active titles for sections! e.g. "fitting the data" instead of
      "perform the fitting"
* do not say "classification emulator"
    - use "emulator and classifier" instead

## Today (25.03)
* write whole chapter Methods
* go through case study 1 and 2
  - adapt results/discussion CS1
  - correct CS2
* adapt and correct introduction

## By tomorrow morning:
* write global discussion
* write conclusion

## Tomorrow
* restructure appendix
* write abstract
* write acknowledgements
* reread and correct the text


## Today (21.03)
* correct case study 1 and send it to mamma's friend for review
* finish writing case study 2

## Keywords
* hierarchical emulator (classifier + time to threshold)


## Chunks of text
--------------------------------------------------------------------------------
Such systems have already been installed in various endangered regions in the world.
After the major flooding of July 2014, the city of Altstätten in the canton of St. Gallen made the decision to install one.
The system installed uses cameras, sensors and level meters to gather data and information about the current situation \autocite{st._galler_tageblatt_altstatten_2017}.

Crucial in order to limit the damages is the intervention time before the actual flooding occurs.
The earlier the dangerous situation can be detected the more time is available to the population and authorities to get ready and set up different types of temporary mitigation measures.
Systems based on sensors monitoring the evolution of the current situation in the upper part of the catchment are quite reliable but do not allow for long anticipation time.

Numerical simulations can be run with meteorological forecast data and approximate soil saturation conditions in order to obtain early predictions of the event outcome.
However, the big advantage of predicting with that much anticipation is partially lost due to the duration of such simulations.
Accurate meteorological forecasts are available only few hours before the event.
If the model require several hours to run, which is often the case to obtain accurate predictions for catchments of this extent, then the advantage of being able to run it in advance is canceled.

A possible solution to this problem is the development of an \emph{early flood warning tool} based on an \emph{ad hoc surrogate model} exploiting the catchment specific behavior.
This early flood warning tool should be able to recognize if a rain event will generate a channel discharge leading to flooding and if yes within how much time.
For this scope two different emulators are used.
The first emulator classifies a rain event based on the forecasted \emph{average rain intensity} and \emph{current soil saturation} into two groups: rain events generating discharge exceeding a chosen threshold ($Q_!$) and rain events not generating discharge exceeding the threshold.
For events exceeding the threshold a second emulator is developed.
This predicts the time the rain event will need to produce the threshold discharge $Q_!$ at the outlet of the catchment.
--------------------------------------------------------------------------------
