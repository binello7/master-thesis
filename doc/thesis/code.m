## Case study 1
# generate 25 discharges in range [0.1, 10} m3/s

nQ  = 25; %number of experiments
Qin = linspace (-0.1, -10, nQ); %Qin values [m3/s]
#-------------------------------------------------------------------------------

## Case study 2
# classifier
meanfunc = {@meanPow,2,{@meanSum,{@meanConst,@meanLinear}}};
mn= [1;1;1];

covfunc = @covSEard;
cv = [1;1;1];

likfunc = @likLogistic;
lk = [];
#-------------------------------------------------------------------------------

# emulator
# evaluation grid
ri_min = min (rain_intensities);
ri_max = max (rain_intensities);
ss_min = min (soil_saturations);
ss_max = max (soil_saturations);
nri = 80;
nss = 80;
[ri_emu ss_emu] = meshgrid ([linspace(ri_min, ri_max, nri)].', ...
                            [linspace(ss_min, ss_max, nss)].');
#-------------------------------------------------------------------------------

# emulator
# test dataset
ri1 = 10 + ((35 - 10) / 9) / 2;
ri2 = 35 - ((35 - 10) / 9) / 2;
rain_intensities_test = [linspace(ri1, ri2, 9)].'; #[mm/h]

ss1 = 0 + ((1 - 0) / 4) / 2;
ss2 = 1 - ((1 - 0) / 4) / 2;
soil_saturations_test = [linspace(ss1, ss2, 4)].';
soil_saturations_test = 1 - soil_saturations_test;
#-------------------------------------------------------------------------------

# emulator
# gaussian process
meanfunc = {@meanPow,2,{@meanSum,{@meanConst,@meanLinear}}};
mn= [1;1;1];

covfunc = @covSEard;
cv = [1;1;1;];

likfunc = @likGauss;
lk = [1];
