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
## Created: 2018-02-06

#clear all
pkg load gpml

## Load data
#
load ('soil_saturations.dat');
load ('soil_saturations_test.dat');
load ('soil_saturations_val.dat');
load ('soil_saturations_svm.dat');
load ('rain_intensities.dat');
load ('rain_intensities_test.dat');
load ('rain_intensities_val.dat');
load ('rain_intensities_svm.dat');
load ('parameters.dat');



## Functions
# MAE: maximum absolute error
function m = mae (y_sim, y_obs)
  m = max (abs (y_sim - y_obs));
endfunction

# MAE%: maximum absolute error %
function m = mae_perc (y_sim, y_obs)
  m = max (max ((abs ((y_sim - y_obs) ./ y_obs * 100))));
endfunction

# RMSE%: root mean sqaure error
function re = rmse (y_sim, y_obs)
  y_sim = y_sim(:);
  y_obs = y_obs(:);
  N = length (y_obs);
  re = sqrt (1/N * sum ((y_sim - y_obs).^2));
endfunction


t_Qtrain  = log10(t_Qtrain);
t_Qtest  = log10(t_Qtest);
t_Qval  = log10(t_Qval);

## Convert \Delta\theta into \theta_i
soil_saturations      = 1 - soil_saturations;
soil_saturations_test = 1 - soil_saturations_test;
soil_saturations_val  = 1 - soil_saturations_val;
soil_saturations_svm  = 1 - soil_saturations_svm;


# ------------------------------------------------------------------------------
## Building the emulators
# create training data mesh
[ri_train ss_train] = meshgrid (rain_intensities, soil_saturations);

## Adding random noise
ss_train   = ss_train + 0.01*randn (size(ss_train));
ri_train   = ri_train + 0.01*randn (size(ri_train));


# create points to evaluate the emulators
ri_min = min (rain_intensities);
ri_max = max (rain_intensities);
[ri_emu ss_emu] = meshgrid ([linspace(ri_min, ri_max, 200)].', [linspace(0, 1, 100)].');

## ------------------------------------------------------------------------------
## Emulator 1: classification
#ri_svm = [ri_train(:); rain_intensities_svm(:)];
#ss_svm = [ss_train(:); soil_saturations_svm(:)];
#x_svm  = [ri_svm ss_svm];
#y_svm  = [t_Qtrain(:); t_Qsvm(:)];


## 1 positive, dangerous situation REACHED!
#y_svm(y_svm<420) = 1;

## -1 negative, dangerous situation NOT reached
#y_svm(y_svm>=420) = -1;

### Use the package gpml
## mean function
#meanfunc = {@meanSum, {@meanConst, {@meanPoly,2}}};
##hyp.mean = [1;1;1;1;1];
##meanfunc = {@meanPow,2,{@meanSum,{@meanConst,@meanLinear}}};
##meanfunc = {@meanSum,{@meanConst,@meanLinear,{@meanProd,{@meanLinear,@meanLinear}}}};
##hyp.mean = [1;1;1;1;1;1;1];

## covariance function
#covfunc = @covSEard;
##hyp.cov = [1;1;1];
##covfunc = {@covMaternard, 1};
##sf = 1.0;
##hyp.cov = log ([1;1;sf]);
##covfunc = @covNoise;
##sf = 1.0;
##hyp.cov = log([sf]);

## likelihood function
#likfunc = @likLogistic;

## prior
##prior.mean=cell(1,7);
##prior.mean{7}={@priorClamped};
##prior.mean{6}={@priorClamped};

## inference method
##infe={@infPrior, @infEP, prior};

#n = length (ri_emu(:));
#hyp = minimize (hyp, @gp, -1e3, @infEP, meanfunc, covfunc, likfunc, x_svm, y_svm);
#[a b c d lp] = gp (hyp, @infEP, meanfunc, covfunc, likfunc, x_svm, y_svm, [ri_emu(:) ss_emu(:)], ones(n, 1));

## plot 1: classification emulator
#figure (2)
#plot (ri_train(t_Qtrain>=420), ss_train(t_Qtrain>=420), 'go', 'markerfacecolor', 'g',...
#      ri_train(t_Qtrain<420), ss_train(t_Qtrain<420), 'ro', 'markerfacecolor', 'r');
#hold on;
#plot (rain_intensities_svm(t_Qsvm>=420), soil_saturations_svm(t_Qsvm>=420), '^g', 'markerfacecolor', 'g')
#plot (rain_intensities_svm(t_Qsvm<420), soil_saturations_svm(t_Qsvm<420), '^r', 'markerfacecolor', 'r')
#contourf(ri_emu, ss_emu, reshape (exp (lp), size (ri_emu)), [0.1 0.25 0.5 0.75 0.9]);
#colorbar
#hold off
#xlabel ('I [mm/h]')
#ylabel ('\theta_i [-]')

# ------------------------------------------------------------------------------
# Emulator 2: regression
# parameters sampling for plotting

# create grid for test and validation
[ri_test ss_test] = meshgrid (rain_intensities_test, soil_saturations_test);
ri_test = ri_test.'; ss_test = ss_test.';

ri_test    = ri_test + 0.01*randn (size(ri_test));
ss_test    = ss_test + 0.01*randn (size(ss_test));

ri_val = rain_intensities_val;
ss_val = soil_saturations_val;

# mean function

meanreg = {@meanConst};
hyp_reg.mean = 0;%[1;1;1];
#meanreg = {@meanPoly,4};
#hyp_reg.mean = [1;1;1;1;1;1;1;1];
#meanfunc = {@meanSum, {@meanConst, {@meanPoly,2}}};
#hyp.mean = [1;1;1;1;1];

# covariacne function
covp = {@covPoly,'ard',3};
covreg = {@covPPard,3};
hyp_reg.cov = [4 2.6 8];
#prior.cov = cell(1,3);
#prior.cov(3) = @priorClamped;

# likelihood function
likreg = @likGauss;
hyp_reg.lik = [-3];
prior.lik = {@priorClamped};

infe = {@infPrior, @infLOO, prior};

tf = t_Qtrain < 420;
tftst = t_Qtest < 420;

xtrn = [ri_train(tf)(:) ss_train(tf)(:); ri_test(tftst)(:) ss_test(tftst)(:)];
ytrn = [t_Qtrain(tf)(:);t_Qtest(tftst)(:)];
args ={infe, meanreg, covreg, likreg, xtrn, ytrn};
tic
hyp_reg = minimize (hyp_reg, @gp, -1e3, args{:});

xemu = [ri_emu(:) ss_emu(:)];

[t_Qemu s2_emu] = gp (hyp_reg, args{:}, xemu);
toc

t_Qemu = reshape (t_Qemu, size (ri_emu));


ri_emu(t_Qemu>=420) = NA;
ss_emu(t_Qemu>=420) = NA;
t_Qemu(t_Qemu>=420) = NA;
figure (3)
htr = plot3 (ri_train(tf), ss_train(tf), t_Qtrain(tf),'ro', 'markerfacecolor', 'r');
hold on
hte = plot3 (ri_test(tftst), ss_test(tftst), t_Qtest(tftst), 'bo', 'markerfacecolor', 'b');
hva = plot3 (rain_intensities_val, soil_saturations_val, t_Qval, 'go', 'markerfacecolor', 'g');
he = mesh (ri_emu, ss_emu, t_Qemu, 'edgecolor', 'k', 'facecolor', 'none')
hold off
legend ([he, htr(1), hte(1), hva(1)], 'emulator', 'training', 'test', 'validation')
xlabel ('I [mm/h]')
ylabel ('\theta_i [-]')
zlabel ('t_! [min]')
grid off;
view (124, 32)


## Performing test and validation
# test
tic
[t_Qemu_test s2_emu_test a b] = gp (hyp_reg, args{:}, [ri_test(tftst)(:) ss_test(tftst)(:)]);
toc
mae_test = mae (t_Qemu_test, t_Qtest(tftst)(:))
rmse_test = rmse (t_Qemu_test, t_Qtest(tftst)(:))

## validation
#tic
#t_Qemu_val = interp2 (ri_train, ss_train, t_Qtrain, rain_intensities_val, soil_saturations_val, method);
#toc
#[mae_val, idx_i, idx_j] = mae (t_Qemu_val, t_Qval)
#mae_val_perc = mae_val / t_Qval(idx_i, idx_j) * 100
#rmse_val = rmse (t_Qemu_val, t_Qval)


