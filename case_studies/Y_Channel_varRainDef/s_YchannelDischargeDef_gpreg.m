## Copyright (C) 2018 Sebastiano Rusca
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.
##
## Author: Sebastiano Rusca <sebastiano.rusca@gmail.com>
## Created: 2018-03-11

#clear all
pkg load gpml

addpath ('../../mfiles/functions');
#addpath ('~/Resources/gpml-matlab-v4.1-2017-10-19');
#startup


## Load data
#
load ('soil_saturations.dat');
load ('soil_saturations_test.dat');
load ('soil_saturations_val.dat');
load ('rain_intensities.dat');
load ('rain_intensities_test.dat');
load ('rain_intensities_val.dat');
load ('t2thold_train.dat');
load ('t2thold_test.dat');
load ('t2thold_val.dat');
load ('parameters.dat');





## Regression with GP
# evaluation points
ri_min = min (rain_intensities);
ri_max = max (rain_intensities);
ss_min = min (soil_saturations);
ss_max = max (soil_saturations);
nri = 80;
nss = 80;
[ri_emu ss_emu] = meshgrid ([linspace(ri_min, ri_max, nri)].', ...
                            [linspace(ss_min, ss_max, nss)].');

## Create full vectors
#
[ri_train ss_train] = meshgrid (rain_intensities, soil_saturations);
ri_train = ri_train(:);
ss_train = ss_train(:);
t_Qtrain = t_Qtrain(:);

[ri_test ss_test] = meshgrid (rain_intensities_test, soil_saturations_test);
ri_test = ri_test(:);
ss_test = ss_test(:);
t_Qtest = t_Qtest(:);

ri_val = rain_intensities_val;
ss_val = soil_saturations_val;


## Add random noise
#ri_test   = ri_test + 0.01*randn (size(ri_test));
#ri_train  = ri_train + 0.01*randn (size(ri_train));


## Mean function
#-------------------------------------------------------------------------------
#meanfunc = {@meanPow,2,{@meanSum,{@meanConst,@meanLinear}}};
#mn= [1;1;1]; # mean function used previously
#-------------------------------------------------------------------------------
#meanfunc = {@meanConst};
#mn = 0;
#meanfunc = [];
#mn = [];
meanfunc = {@meanSum,{@meanConst,@meanLinear,{@meanPoly,2}}};
mn = rand (7,1);


# covariacne function
covfunc = {@covPoly,'iso',3};
cv = rand (3,1);
#covfunc = @covNoise;
##cv = 1;
#covfunc = {@covPPard,3};
#cv = [4 2.6 8];
#covfunc = {@covMaternard,1};
#cv = [1;1;1];
#covfunc = @covSEard;
#cv = [1;1;1;];




# likelihood function
likfunc = @likGauss;
lk = [1];



# inference method
#prior.lik = {@priorClamped};
#prior.cov = cell(1,3);
#prior.cov(3) = @priorClamped;
#infe = {@infPrior, @infLOO, prior};
infe = @infExact;


## Initialize the hyperparameters
hyp.mean = mn;
hyp.cov  = cv;
hyp.lik  = lk;


tf = t_Qtrain < 420;
tftst = t_Qtest < 420;


xtrn = [ri_train(tf) ss_train(tf)];#ri_test(tftst)(:) ss_test(tftst)(:)];
ytrn = [t_Qtrain(tf)];#t_Qtest(tftst)];
xemu = [ri_emu(:) ss_emu(:)];

args ={infe, meanfunc, covfunc, likfunc, xtrn, ytrn};

# minimize the negative log marginal likelihood
tic
hyp = minimize (hyp, @gp, -2e3, args{:});
toc


#load ('hyp_reg.dat');
tic
t_Qemu = gp (hyp, args{:}, xemu);
toc

#save ('hyp_reg.dat', 'hyp');

t_Qemu = reshape (t_Qemu, size (ri_emu));


## Plot the emulator
tfemu = t_Qemu >= 420;
ri_emu(tfemu) = NA;
ss_emu(tfemu) = NA;
t_Qemu(tfemu) = NA;

figure (3)
htr = plot3 (ri_train(tf), ss_train(tf), t_Qtrain(tf),'ro', 'markerfacecolor', 'r');
hold on
hte = plot3 (ri_test(tftst), ss_test(tftst), t_Qtest(tftst), 'bo', 'markerfacecolor', 'b');
hva = plot3 (rain_intensities_val, soil_saturations_val, t_Qval, 'go', 'markerfacecolor', 'g');
he = mesh (ri_emu, ss_emu, t_Qemu, 'edgecolor', 'k', 'facecolor', 'none');
hold off
legend ([he, htr(1), hte(1), hva(1)], 'emulator', 'training', 'test', 'validation')
xlabel ('I [mm/h]')
ylabel ('\theta_i [-]')
zlabel ('t_! [min]')
grid off;
view (124, 32)
print ('emulator.png', '-r300');

## Performing test and validation
# test
tic
t_Qemu_test = gp (hyp, args{:}, [ri_test(tftst) ss_test(tftst)]);
toc
mae_test      = MaxAE (t_Qemu_test, t_Qtest(tftst))
mae_test_perc = MaxAPE (t_Qemu_test, t_Qtest(tftst))
rmse_test = rmse (t_Qemu_test, t_Qtest(tftst))

# validation
tic
t_Qemu_val = gp (hyp, args{:}, [ri_val ss_val]);
toc
mae_val      = MaxAE (t_Qemu_val, t_Qval)
mae_val_perc = MaxAPE (t_Qemu_val, t_Qval)
rmse_val     = rmse (t_Qemu_val, t_Qval)

tic
t_Qemu_1val = gp (hyp, args{:}, [30 0.1])
toc


# Propagation of uncertainty
c = 100;
r = length (soil_saturations_val);
sigma = 0.02;
iss_uncert = normrnd (repmat (soil_saturations_val, 1, c), ...
                      sigma*repmat (soil_saturations_val, 1, c));

for i = 1:c
  t_Quncert(:,i) = gp (hyp, args{:}, [ri_val iss_uncert(:,i)]);
endfor



