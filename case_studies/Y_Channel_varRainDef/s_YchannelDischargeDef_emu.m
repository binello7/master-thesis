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
load ('qt_bbound_mat.dat');
load ('qt_bbound_test.dat');
load ('qt_bbound_val.dat');
load ('qt_bbound_svm.dat');
load ('soil_saturations.dat');
load ('soil_saturations_test.dat');
load ('soil_saturations_val.dat');
load ('rain_intensities.dat');
load ('rain_intensities_test.dat');
load ('rain_intensities_val.dat');
load ('rain_intensities_svm.dat');
load ('soil_saturations_svm.dat');
load ('parameters.dat');

rain_intensities = rain_intensities * 1000 * 3600; #[mm/h]
rain_intensities_test = rain_intensities_test * 1000 * 3600; #[mm/h]
rain_intensities_val = rain_intensities_val * 1000 * 3600; #[mm/h]

nExp = length (qt_bbound);
nInt = length (rain_intensities);
nSat = length (soil_saturations);


## Functions
# MAE: maximum absolute error
function [m i j] = mae (y_sim, y_obs)
  mtemp = 0;
  [mtemp i] = max ((abs (y_sim - y_obs)), [], 1);
  [m j] = max (mtemp, [], 2);
  i = i(j);
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



## Extract the idx of Q exceeding Q threshold
# training data
Q_trhsh = 0.17; #[m3/s];
idx_thrsh = zeros (nSat, nInt);
for i = 1:nInt
  for s = 1:nSat
    [Qmax(s,i) idx_max(s,i)] = max (qt_bbound(:,i,s));
    if isempty (find (qt_bbound(:,i,s) >= Q_trhsh, 1))
      idx_thrsh(s,i) = 7*60;
    else
      idx_thrsh(s,i) = find (qt_bbound(:,i,s) >= Q_trhsh, 1);
      idx_thrsh(s,i) = idx_thrsh(s,i) - 0.5; #threshold was exceeded between this index and the previous one -> average
    endif
  endfor
endfor

# test data
j = 1;
idx_tests = zeros (length (soil_saturations_test), length (rain_intensities_test));
for s = 1:length(soil_saturations_test)
  for i = 1:length(rain_intensities_test)
    if isempty (find (qt_bbound_test(j,:) >= Q_trhsh, 1))
      idx_test(s,i) = 7*60;
    else
      idx_test(i,s) = find (qt_bbound_test(j,:) >= Q_trhsh, 1);
      idx_test(i,s) = idx_test(i,s) - 0.5;
    endif
    j+=1;
  endfor
endfor

# validation data
idx_vals = zeros (1, length (rain_intensities_val));
for i = 1:length(rain_intensities_val)
  if isempty (find (qt_bbound_val(i,:) >= Q_trhsh, 1))
    idx_val(i) = 7*60;
  else
    idx_val(i) = find (qt_bbound_val(i,:) >= Q_trhsh, 1);
    idx_val(i) = idx_val(i) - 0.5;
  endif
endfor

# svm classifier
idx_svm = zeros (1, length (rain_intensities_svm));
for i = 1:length(rain_intensities_svm)
  if isempty (find (qt_bbound_svm(i,:) >= Q_trhsh, 1))
    idx_svm(i) = 7*60;
  else
    idx_svm(i) = find (qt_bbound_svm(i,:) >= Q_trhsh, 1);
    idx_svm(i) = idx_svm(i) - 0.5;
  endif
endfor



# converting the index in time
t_Qtrain   = idx_thrsh * dt / 60; #[min]
t_Qtest = idx_test * dt / 60; #[min]
t_Qval = transpose (idx_val * dt / 60); #[min]
t_Qtsvm = transpose (idx_svm * dt / 60); #[min]


## Building the emulator
# extracting the parameters making the regular grid
sat_train = soil_saturations;
ri_train  = rain_intensities;
[ri_train sat_train] = meshgrid (ri_train, sat_train);

# emu - SVM classifier
ri_svm = [ri_train(:); rain_intensities_svm(:)];
sat_svm = [sat_train(:); soil_saturations_svm(:)];

# parameters sampling for plotting
# x1: rain intensity, x2 = soil saturation
[x1 x2] = meshgrid ([linspace(min (ri_train(:)), max (ri_train(:)), 200)].', [linspace(0, 1, 100)].');
x = [x1(:) x2(:)];
n = length (x);
 

x_svm = [ri_svm sat_svm];
t_Qsvm = [t_Qtrain(:); t_Qtsvm(:)];
t_Qsvm(t_Qsvm<420) = 1;
t_Qsvm(t_Qsvm>=420) = -1;

meanfunc = {@meanSum, {@meanConst, {@meanPoly,2}}};
#meanfunc = {@meanPow,2,{@meanSum,{@meanConst,@meanLinear}}};
#meanfunc = {@meanSum,{@meanConst,@meanLinear,{@meanProd,{@meanLinear,@meanLinear}}}};
hyp.mean = [18;-15.2;-127;1.3;-10];
#hyp.mean = [4;1;1];
#hyp.mean = [418;-15;-127;9;36;1;1];
#covfunc = {@covMaternard, 1};
covfunc = {@covNoise};
#ell = ones(2,1);
#sf = 1.0;
hyp.cov = log([sf]);
likfunc = @likLogistic;
#prior.mean=cell(1,7);
#prior.mean{7}={@priorClamped};
#prior.mean{6}={@priorClamped};

infe={@infPrior, @infEP, prior};

hyp = minimize (hyp, @gp, -1e3, infe{2}, meanfunc, covfunc, likfunc, x_svm, t_Qsvm);
[a b c d lp] = gp (hyp, infe{2}, meanfunc, covfunc, likfunc, x_svm, t_Qsvm, x, ones(n, 1));

# 2D plot for SVM
figure (2)

plot (ri_train(t_Qtrain>=420), sat_train(t_Qtrain>=420), 'go', 'markerfacecolor', 'g',...
      ri_train(t_Qtrain<420), sat_train(t_Qtrain<420), 'ro', 'markerfacecolor', 'r');
hold on;
plot (rain_intensities_svm(t_Qtsvm>=420), soil_saturations_svm(t_Qtsvm>=420), '^g', 'markerfacecolor', 'g')
plot (rain_intensities_svm(t_Qtsvm<420), soil_saturations_svm(t_Qtsvm<420), '^r', 'markerfacecolor', 'r')
contourf(x1, x2, reshape(exp(lp), size(x1)), [0.25 0.5 0.75]);
colorbar
hold off



# emu - time to peak

# create sampling for the emulator
sat_emu = linspace (0, 1, 100);
ri_emu  = linspace (min (min (ri_train)), max (max (ri_train)), 100);
[ri_emu sat_emu] = meshgrid (ri_emu, sat_emu);

# create grid for test and validation
[ri_test sat_test] = meshgrid (rain_intensities_test, soil_saturations_test);

## Generating the plot for the emulator
#
method = 'cubic';
#t_Qts_emu_na = interp2 (ri_train, sat_train, t_Qtrain_na, ri_emu, sat_emu, 'nearest');
t_Qts_emu = interp2 (ri_train, sat_train, t_Qtrain, ri_emu, sat_emu, method);

# 3D plot of the emulator
figure (1)
htr = plot3 (ri_train, sat_train, t_Qtrain, 'ro', 'markerfacecolor', 'r');
hold on
hte = plot3 (ri_test, sat_test, t_Qtest, 'bo', 'markerfacecolor', 'b');
hva = plot3 (rain_intensities_val, soil_saturations_val, t_Qval, 'go', 'markerfacecolor', 'g');
he = mesh (ri_emu, sat_emu, t_Qts_emu, 'edgecolor', 'k', 'facecolor', 'none');
hold off
legend ([he, htr(1), hte(1), hva(1)], 'emulator', 'training', 'test', 'validation')
xlabel ('ri [mm/h]')
ylabel ('\Delta\theta [-]')
zlabel ('t(Q_{thrsh}) [min]')
grid off;
view (124, 32)
print ('emulator.eps', '-color')
print ('emulator.png', '-r300')




## Performing test and validation
# test
[ri_test sat_test] = meshgrid (rain_intensities_test, soil_saturations_test);
tic
t_Qemu_test = interp2 (ri_train, sat_train, t_Qtrain, ri_test, sat_test, method);
toc
[mae_test, idx_i, idx_j] = mae (t_Qemu_test, t_Qtest)
mae_test_perc = mae_test / t_Qtest(idx_i, idx_j) * 100
rmse_test = rmse (t_Qemu_test, t_Qtest)
#rmse_val_perc =

# validation
tic
t_Qemu_val = interp2 (ri_train, sat_train, t_Qtrain, rain_intensities_val, soil_saturations_val, method);
toc
[mae_val, idx_i, idx_j] = mae (t_Qemu_val, t_Qval)
mae_val_perc = mae_val / t_Qval(idx_i, idx_j) * 100
rmse_val = rmse (t_Qemu_val, t_Qval)







