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

#pkg load gpml
addpath ('../../mfiles/functions');
addpath ('~/Resources/gpml-matlab-v4.1-2017-10-19');
startup

## Load data
#
load ('soil_saturations.dat');
load ('soil_saturations_test.dat');
load ('soil_saturations_svm.dat');
load ('rain_intensities.dat');
load ('rain_intensities_test.dat');
load ('rain_intensities_svm.dat');
load ('t2thold_train.dat');
load ('t2thold_test.dat');
load ('t2thold_class.dat');
load ('parameters.dat');



## Functions

# MAE%: maximum absolute error %
#function m = mae_perc (y_sim, y_obs)
#  m = max (max ((abs ((y_sim - y_obs) ./ y_obs * 100))));
#endfunction

## RMSE%: root mean sqaure error
#function re = rmse (y_sim, y_obs)
#  y_sim = y_sim(:);
#  y_obs = y_obs(:);
#  N = length (y_obs);
#  re = sqrt (1/N * sum ((y_sim - y_obs).^2));
#endfunction


## SVM classification with GP
# create training data mesh
[ri_train ss_train] = meshgrid (rain_intensities, soil_saturations);


# prepare the data
ri_class = [ri_train(:);rain_intensities_svm(:)];
ss_class = [ss_train(:);soil_saturations_svm(:)];
x_class  = [ri_class ss_class];
y_class  = [t_Qtrain(:);t_Qclass(:)];


## Evaluation points
ri_min = min (rain_intensities);
ri_max = max (rain_intensities);
nri = 200;
nss = 100;
[ri_eval,ss_eval] = meshgrid ([linspace(ri_min, ri_max, nri)].', [linspace(0, 1, nss).']);


# 1 positive, threshold REACHED!
y_class(y_class<420) = 1;

# -1 negative, threshold NOT reached
y_class(y_class>=420) = -1;

## Use the package gpml
# Mean function
meanfunc = [];
mn = [];
#meanfunc = @meanConst;
#mn = 0;
#meanfunc = @meanLinear;
#mn = [1;1];
#meanfunc = {@meanPoly,2};
#mn = [1;1;1;1]
#meanfunc = {@meanPoly,3};
#mn = [1;1;1;1;1;1];
#meanfunc = {@meanSum, {@meanConst, {@meanPoly,2}}};
#hyp.mean = [1;1;1;1;1];
#meanfunc = {@meanSum, {@meanConst, {@meanLinear}}};
#hyp.mean = [1;1;1];
#meanfunc = {@meanPow,2,{@meanSum,{@meanConst,@meanLinear}}};
#mn= [1;1;1];
#meanfunc = {@meanSum,{@meanConst,@meanLinear,{@meanProd,{@meanLinear,@meanLinear}}}};
#mn = [1;1;1;1;1;1;1];

# Covariance function
covfunc = @covSEard;
cv = [1;1;1];
#covfunc = {@covMaternard, 1}; #1.64e01
#cv = log ([1;1;1]);
#covfunc = @covNoise;
#cv = 0;
#covfunc = {@covPoly,'ard',3};
#cv = [1;0;0];
#covfunc = @covZero;
#cv = [];


# Likelihood function
likfunc = @likLogistic;
lk = [];


#hyp.mean = mn;
#hyp.cov  = cv;
#hyp.lik  = lk;

## Prior
#prior.mean=cell(1,7);
#prior.mean{7}={@priorClamped};
#prior.mean{6}={@priorClamped};

## Inference method
infe = @infEP;
#infe={@infPrior, @infEP, prior};

args = {infe, meanfunc, covfunc, likfunc};


hyp = minimize (hyp, @gp, -1e3, args{:}, x_class, y_class);
lp = gp (hyp, args{:}, x_class, y_class, [ri_eval(:) ss_eval(:)], ones(nri*nss, 1));

## Generate the plot
red = t_Qtrain < 420;
green = t_Qtrain >= 420;
figure (1)
plot (ri_train(green), ss_train(green), 'go', 'markerfacecolor', 'g',...
      ri_train(red), ss_train(red), 'ro', 'markerfacecolor', 'r');
hold on;
plot (rain_intensities_svm(t_Qclass>=420), soil_saturations_svm(t_Qclass>=420), '^g', 'markerfacecolor', 'g')
plot (rain_intensities_svm(t_Qclass<420), soil_saturations_svm(t_Qclass<420), '^r', 'markerfacecolor', 'r')
contourf(ri_eval, ss_eval, reshape (exp (lp), size (ri_eval)), [0.49 0.5 0.51]);
colorbar
hold off
xlabel ('I [mm/h]')
ylabel ('\theta_i [-]')




## ------------------------------------------------------------------------------
### Building the emulators
## create training data mesh
#[ri_train ss_train] = meshgrid (rain_intensities, soil_saturations);

### Adding random noise
#ss_train   = ss_train + 0.01*randn (size(ss_train));
#ri_train   = ri_train + 0.01*randn (size(ri_train));


## create points to evaluate the emulators
#ri_min = min (rain_intensities);
#ri_max = max (rain_intensities);
#[ri_emu ss_emu] = meshgrid ([linspace(ri_min, ri_max, 200)].', [linspace(0, 1, 100)].');

## ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
