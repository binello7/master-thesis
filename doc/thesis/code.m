## Case study 1
# generate 25 discharges in range [0.1, 10} m3/s

nQ  = 25; # number of experiments
Qin = linspace (-0.1, -10, nQ); # Qin values [m3/s]



#-------------------------------------------------------------------------------


## Case study 2
# classifier
# classifier's mean, covariance and likelyhood functions:
meanfunc = {@meanPow,2,{@meanSum,{@meanConst,@meanLinear}}};
covfunc  = @covSEard;
likfunc  = @likLogistic;

# classifier's hyperparameters arbitrary initial values:
mn = [1;1;1];
cv = [1;1;1];
lk = [];



#-------------------------------------------------------------------------------


## Emulator - evaluation grid
# set the limits of the domain (no extrapolation)
ri_min = min (rain_intensities);
ri_max = max (rain_intensities);
ss_min = min (soil_saturations);
ss_max = max (soil_saturations);

# 80 pts. ri, 80 pts. ss; tot. 6400 evaluations
nri = 80; # pts. rain intensity
nss = 80; # pts. initial soil saturation

# crate the mesh of all combinations
[ri_emu ss_emu] = meshgrid ([linspace(ri_min, ri_max, nri)].', ...
                            [linspace(ss_min, ss_max, nss)].');



#-------------------------------------------------------------------------------


## Emulator - test dataset
## Test data points in the centre of the training dataset mesh
# rain intensity: 1st and last point location
maxri = 35; minri = 10; # max, min ri values
nri = 9; # n. ri values
ri1 = minri + ((maxri - minri) / nri) / 2; # ri value 1st point (center)
ri2 = maxri - ((maxri - minri) / nri) / 2; # ri value last point (center)

# all ri values
rain_intensities_test = [linspace(ri1, ri2, nri)].'; #[mm/h]

# initial soil saturation: 1st and last point location
maxss = 1; minss = 0; # max, min ss values
nss = 4; # n. ss values
ss1 = minss + ((maxss - minss) / nss) / 2; # ss value 1st point (center)
ss2 = maxss - ((maxss - minss) / nss) / 2; # ss value last point (center)

# all ss values
soil_saturations_test = [linspace(ss1, ss2, nss)].'; #[-]



#-------------------------------------------------------------------------------


# emulator
# gaussian process
# emulator's mean, covariance and likelyhood functions:
meanfunc = {@meanPow,2,{@meanSum,{@meanConst,@meanLinear}}};
covfunc  = @covSEard;
likfunc  = @likGauss;

# emulator's hyperparameters arbitrary initial values:
mn = [1;1;1];
cv = [1;1;1;];
lk = [1];



#-------------------------------------------------------------------------------


# emulator's hyperparameters
hyp_emu =

  scalar structure containing the fields:

    mean =

       46.6198
       -1.2804
       -9.3105

    cov =

       1.39468
       0.26833
       6.01698

    lik =  0.87122



#-------------------------------------------------------------------------------


# classifier's hyperparameters
hyp_class =

  scalar structure containing the fields:

    mean =

      -95.0746
        7.3285
       41.8132

    cov =

       9.55791
      -0.37870
       6.48165

    lik = [](0x0)


