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

addpath ('../../mfiles/functions');
addpath ('~/Resources/gpml-matlab-v4.1-2017-10-19');
startup


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
nri = 200;
nss = 100;
[ri_emu ss_emu] = meshgrid ([linspace(ri_min, ri_max, nri)].', [linspace(0, 1, nss)].');

## Create grid for training, test and validation
#
[ri_train ss_train] = meshgrid (rain_intensities, soil_saturations);

[ri_test ss_test] = meshgrid (rain_intensities_test, soil_saturations_test);

ri_val = rain_intensities_val;
ss_val = soil_saturations_val;


## Add random noise
#ri_test    = ri_test + 0.01*randn (size(ri_test));
#ss_test    = ss_test + 0.01*randn (size(ss_test));

## Transform the data
#t_Q

## Mean function
meanfunc = {@meanConst};
mn = 0;
#meanfunc = {@meanPoly,4};
#mn = [1;1;1;1;1;1;1;1];


# covariacne function
#covfunc = {@covPoly,'ard',3};
covfunc = {@covPPard,3};
cv = [4 2.6 8];
#prior.cov = cell(1,3);
#prior.cov(3) = @priorClamped;

# likelihood function
likfunc = @likGauss;
lk = [-3];

## Initialize the hyperparameters
hyp.mean = mn;
hyp.cov  = cv;
hyp.lik  = lk;

#prior.lik = {@priorClamped};

infe = @infLOO;
#infe = {@infPrior, @infLOO, prior};

tf = t_Qtrain < 420;
tftst = t_Qtest < 420;

xtrn = [ri_train(tf)(:) ss_train(tf)(:); ri_test(tftst)(:) ss_test(tftst)(:)];
ytrn = [t_Qtrain(tf)(:);t_Qtest(tftst)(:)];

args ={infe, meanfunc, covfunc, likfunc, xtrn, ytrn};
tic
hyp = minimize (hyp, @gp, -1e3, args{:});

xemu = [ri_emu(:) ss_emu(:)];

[t_Qemu s2_emu] = gp (hyp, args{:}, xemu);
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
[t_Qemu_test s2_emu_test a b] = gp (hyp, args{:}, [ri_test(tftst)(:) ss_test(tftst)(:)]);
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

