# Master thesis
This repository contains all of the material relevant for my Master Thesis (November 2017 - March 2018).  
To download the final report, slides used for the presentations, etc. go down to [Downloads](#Downloads)

Code in this repository makes use of tools from the [fswof2d](https://github.com/binello7/fswof2d) repository, which contains an Octave package easing the interaction with the simulator used ([FullSWOF_2D](https://sourcesup.renater.fr/projects/fullswof-2d/)).

## Description
**Development of an Overland Flow Model Emulator**

Flooding and inundation have dramatically increased in the last years due to climate change. To
limit the risks and damage, novel control, mitigation, and warning measures are needed.

However, before major infrastructure investments are in place, the real effectiveness of these
measures has to be evaluated. A very powerful tool to do it is numerical simulation. Simulation,
despite his low cost and feasibility, also presents some drawbacks and difficulties. Due to the
complexity of flood wave propagation in urban environments and floodplains, computations can
take very long. This renders impractical the use of warning systems based on numerical simulation.
The same problem affects the design and analysis of control or mitigation measures. For these
measures hundred of thousands of simulations have to be run to calibrate model parameters or to
study and compare different scenarios. For example, model calibration using current numerical
models based on shallow water equations can last up to several weeks.

There are four approaches to deal with this problem: i) discard systems analysis and intelligent
control strategies, ii) work only with utterly simplified models, iii) use high-performance computing
(HPC), and iv) construct fast surrogate models. The first two are inefficient and the third, using
HPC, often requires considerable investment in HPC know-how and IT equipment. It often also
requires re-programming simulation software, which is not always the best strategy for all projects
and problems. Therefore, constructing fast surrogate models, so-called emulators, to speed up slow
simulators is very attractive. It does not require a huge investment in new hardware and software,
and the same tool can be used to solve very different problems. Emulators are “data-driven
constructed models which mimic the behavior of the simulation models as closely as possible while
being computationally cheaper to evaluate<sup>1</sup>”. A limited number of simulations at intelligently
chosen points has to be run with the original simulator, from these the emulator can learn the
behavior of the system and generate approximations of the relevant observables.

The objective of this Master thesis is to develop emulators for the widely accepted overland flow
model base on the 2D shallow water equations (Saint-Venant), and applied to a specific case study.
This model is implemented in several open source simulators, such as FullSWOF, FLOW-R2D, and
CADDIES which will be used to generate the datasets required for the construction of the emulator.

The following is a list of some of the main tasks for this Master thesis:
* Build an emulator for toy scenarios: i) with analytical solutions and, ii) very simple
domains.
* Develop an emulator for a simple case study, e.g. a dam break simulation. Possibility of
developing an emulator for the simulation of the “Tous dam break” with FLOW-R2D, for
which a dataset is already available 2 .
* Select more realistic scenarios (possibly real-life case studies) and setup the simulators.
Build an emulator for these scenarios. The scenario will cover: i) optimization of flood
protection measures, ii) water level uncertainty quantification, iii) early flood warning
systems.

Two intermediate meetings will be scheduled during the 18 weeks master thesis period. The first
one will be held during the 6 th week of the master thesis period and the second one during the 12 th .
The exact dates will be fixed later. Aim of these meetings is to take stock of the situation, possibly
provide the student with new materials/ideas and make the supervisors and professor aware of the
state of progress.

1. “Surrogate Model.” 2017. Wikipedia. https://en.wikipedia.org/w/index.php?title=Surrogate_model&oldid=772207388

---

## Downloads
### Thesis
* [Master Thesis](doc/thesis/SR_MThesis_Emulation.pdf)

### Presentations
* [Presentation eawag](doc/pres/pres_mseminar/Msem_Presentation.pdf) ("Montag Seminar")
* [Presentation 1](doc/pres/pres01/01_Presentation.pdf)
* [Presentation 2](doc/pres/pres02/02_Presentation.pdf)
* [Final Presentation](doc/pres/pres03/03_Presentation.pdf)

### IAHR 2018 (Trento)
* [Abstract](doc/IAHR/Abstract/Abstract_SRusca.pdf)
* [Presentation](doc/IAHR/Presentation/Early-flood-warning_Pres.pdf)
