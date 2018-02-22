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
## Created: 2018-01-24

close all
clear all
pkg load optim

## To discuss
#
# 3.2.a We have 11 points, we want to interpolate. Derivative changes sign 2 
#       times (y(:,2)) in the visible domain. Right side the value seems to explode
#       (no more oscillations), left side there might be a further oscillation 
#       (or even more!!). Try with polynomes deg. 3, 4, 5. Polynome deg. 3 does
#       not interpolate! Intuition: Although derivative changes only 2 times, in the visible data, 
#       the 3rd change is already intrinsec (first point decreases
#       too little). For this reason polynome deg. 3 doesn not work. Is this correct?
#       Polynomes deg. 4 or higher all work but 4 is the lowest degree!!
#       How to choose the correct one? The one with the lowest mse is 

# 3.2.b What is asked with "compute uncertainty in polynomial model"? just dp??
#       dp is clear, it is the standard deviation of the p coefficients.

# 3.2.c I computed dp with the jackknife method. dy not asked here (just 'model unertainty')

# 3.2.d Do we have to take into account cross-correlation within parameters for the propagation?
#       (see formula wikipedia, propagation of uncertainty)

# 3.2.e What is meant? I computed the difference (absolute value) between the given outputs and
#       outputs computed with the model (with p_est). In the intrapolation: linear interpolation between
#       error at one output point and error at the following?? (doesn't really make sense...)


## Data
#
dataFolder = 'data';
fname = @(s) fullfile ('..', dataFolder, s);
dataFile = fname ('interpolation1D_poly1.dat');
data = load (dataFile);

X    = data(:,1);
Y    = data(:,3);
nx   = length (X);

## Add random noise
#
#Yn = Y + 0.4*randn (size(Y));
Yn = Y;

# create a vector of x-values for the plots
xp = transpose (linspace (1.1*min (X), 1.1*max (X), 200));


## Functions
# simple functions to do loo
se_o_f      = @(xy,xyt,n) (polyval ( polyfit (xy(:,1), xy(:,2), n), xyt(:,1)) - xyt(:,2)).^2;
mse_o_f     = @(xy, loo, n) mean(arrayfun (@(i)se_o_f(xy(loo(i,:),:), xy(!loo(i,:),:), n), 1:size(loo,1)));
mse         = @(y, yf) mean ((y - yf).^2);
ind_loo     = @(nx) ! logical (eye (nx));
p_est_jk_f  = @(x, y, loo, ln) cell2mat (transpose (arrayfun (@(i) polyfit (x(loo(:,i)), y(loo(:,i)), ln), 1:length(x), 'uniformoutput', false)));


function dy = dypp (x, dp, ev)
# sf^2 = (df/dp1)^2 * sp1^2 + (df/dp2)^2 * sp2^2 + ...
# propagates the errot to the output using the above formula (polynomes)
  dy = sqrt (sumsq (x.^ev .* dp.', 2));
endfunction

function dy = dylo (p, x, y)
  for i = 1:length (x)
    dy(i,1) = abs (y(i) - polyval (p, x(i)));
  endfor
endfunction


function sdjk = jk_stdv (p)
  n = length (p);
  p_m = mean (p);
  sdjk = transpose (sqrt ((n-1) / n * sum (cell2mat (transpose (arrayfun (@(i) ((p(i,:) - p_m).^2), 1:n, 'uniformoutput', false))), 1)));
endfunction

function plot_CI (x, y, xt, yt, p, dy, tit)
  yt = polyval (p, xt);
  plot (x, y, 'o', xt, yt, 'k-', 'linewidth', 1.5);
  axis tight
  hold on
  plot (xt, yt+dy*[-1 1],'r');
  hold off
  title (sprintf ('%s', tit))
  xlabel ('x');
  ylabel ('y');
  legend ('data', 'fit', 'CI', 'CI', 'location', 'northwest')
endfunction


# functions for linear filter
# linear triangular
function yL = phi_L (x, xi, sigma)
  for i = 1:length(xi)
    for j = 1:length(x)
      if x(j) < xi(i) - sigma || x(j) > xi(i) + sigma
        yL(j,i) = 1;
      elseif x(j) >= xi(i) - sigma && x(j) <= xi(i)
        yL(j,i) = (x(j) - xi(i)) / sigma + 1;
      elseif x(j) >= xi(i) && x(j) <= xi(i) + sigma
        yL(j,i) = -(x(j) - xi(i)) / sigma + 1;
      endif
    endfor
  endfor
endfunction

# squared exponential (SE)
phi_SE   = @(x, sigma) exp (- (x - X.').^2 / (2*sigma^2)); 






## Visualize the data
f = 1;
figure (f);
f+=1;
plot (X, Y, 'bo')
axis tight
grid on

# the derivative of the function generating the data changes sign 4 times.
# the polynome is then at least of degree 5. We have 11 points. We can then be
# sure that a polynome of degree 11 will interpolate the points.





e_min = 3;         # minimum exponent
e_max = e_min + 2; # maximum exponent: e_min + 2

##
# every exponent can be considered (1) or not (0). If the exponent max is 3
# then we have 4 coefficients (^0 also to be considered). The case [0 0 0 0] is
# of course not considered.
n_tot = 2^(e_max + 1) -1;
n_not = 2^(e_min) - 1;


e_sets = dec2bin (n_not+1:n_tot) =='1';
n_sets = length (e_sets);

ind = ind_loo (nx);

# [p s] = polyfit (x, y, n)
# p: coefficients of polynomial. First value x with highest degree, last value x^0
tic
mse_e = zeros (n_sets, 1);
for i = 1:n_sets;
  mse_e(i,1) = mse_o_f ([X Y], ind, e_sets(i,:));
endfor
toc

[~, idx_min] = min(mse_e);
idx_right = 19;
[mse_e idx_mse] = sortrows (mse_e, 1);

# possible sets of polynomes generating the data. The coefficients values are still to determine.
# for mse_e < eps the error is zero, we are interpolating. If the error is bigger we are minimizing
# it but not interpolating (can be discarded). We can choose the simplest model within e_pos!!
# The simplest model will be the one having more 'zeros'. All polynomes interpolating
# are at least degree 4. Summing active (1) and inactive (0) coefficients, the one with the
# lowest value will be the easiest model!
idx_pos = idx_mse(mse_e < eps);
e_pos   = e_sets(idx_pos,:);
[~, idx_min] = min (arrayfun (@(i) sum (e_pos(i,:)), 1:size (e_pos)(1)));
idx_min = idx_mse(idx_min);

## Find the coefficients of the simplest model
# the simplest model is the one with index 'idx_min'
e_simp = e_sets(idx_min,:);
ee_simp = length (e_simp) - find (e_simp);
[p_est s] = polyfit (X, Yn, e_simp);


## Uncertainty calculations
# method: polyfit output 
# uncertainty in the model (in p)
dp_pf = sqrt (diag (s.C)/s.df)*s.normr;
dp_pf = dp_pf(e_simp != 0);


# method: jackknife
# uncertainty in the model (in p)
p_est_jk = p_est_jk_f (X, Y, ind, e_simp);
dp_jk = jk_stdv (p_est_jk);
dp_jk = dp_jk(e_simp != 0);

# propagation of uncertainty to output (dy)
ye = polyval (p_est, xp);
dypo = dypp (xp, dp_pf, ee_simp);

# calculation of uncertainty with leave one out of sample error estimation
dyle = dylo (p_est, X, Y, 10);


## Plot the interpolation results
figure (f)
f+=1;
plot_CI (X, Y, xp, ye, p_est, dypo, '')


## 3.3 Linear filter
# 3.3.b.L
sL = [1.5 1.8 2 3];


figure (f)
f+=1;
plot (X, Y, 'o');

for i = 1:length(sL)
# compute the weights using observed input-output
  wL = phi_L (X, X, sL(i)) \ Y;

# plot the solution in the xp span
  yL = phi_L(xp, X, sL(i)) * wL;
  hold on
  plot (xp, yL);
  hold off
  leg{i+1} = sprintf ('\\sigma = %0.1f', sL(i));
endfor
leg{1} = 'data';
legend (leg);
clear leg

# 3.3.b.SE
# choose a value for sigma
sSE = [0.05 0.1 0.2 1];

figure (f)
f+=1;
plot (X, Y, 'o');

for i = 1:length (sSE)
# compute the weights using observed input-output
  wSE = phi_SE (X, sSE(i)) \ Y;

# plot the solution in the xp span
  ySE = phi_SE (xp, sSE(i)) * wSE;
  hold on
  plot (xp, ySE)
  hold off
  leg{i+1} = sprintf ('\\sigma = %0.2f', sSE(i));
endfor
leg{1} = 'data';
legend (leg);











