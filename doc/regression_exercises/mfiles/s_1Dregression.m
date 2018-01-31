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




## Simple functions to do LOO
#
se_o_f      = @(xy,xyt,n) (polyval ( polyfit (xy(:,1), xy(:,2), n), xyt(:,1)) - xyt(:,2)).^2;
mse_o_f     = @(xy, loo, n) mean(arrayfun (@(i)se_o_f(xy(loo(i,:),:), xy(!loo(i,:),:), n), 1:size(loo,1)));
mse         = @(y, yf) mean ((y - yf).^2);
ind_loo     = @(nx) ! logical (eye (nx));
p_est_jk_f  = @(x, y, loo, ln) cell2mat (transpose (arrayfun (@(i) polyfit (x(loo(:,i)), y(loo(:,i)), ln), 1:length(x), 'uniformoutput', false)));


function dy = dyp (x, dp, ev)
# sf^2 = (df/dp1)^2 * sp1^2 + (df/dp2)^2 * sp2^2 + ...
# propagates the errot to the output using the above formula (polynomes)
 dy = sqrt (sumsq (x.^ev .* dp.', 2));
endfunction

function sdjk = jk_stdv (p)
  n = length (p);
  p_m = mean (p);
  sdjk = transpose (sqrt ((n-1) / n * sum (cell2mat (transpose (arrayfun (@(i) ((p(i,:) - p_m).^2), 1:n, 'uniformoutput', false))), 1)));
endfunction

function plot_CI (x, y, xt, p, dp, ev, tit)
  yt = polyval (p, xt);
  plot (x, y, 'o;data;', xt, yt, 'k-;fit;');
  axis tight
  hold on
  plot (xt, yt+dyp(xt, dp, ev)*[-1 1],'r-;CI;');
  hold off
  title (sprintf ('%s', tit))
  xlabel ('x');
  ylabel ('y');
endfunction




## Data
#
dataFolder = 'data';
fname = @(s) fullfile ('..', dataFolder, s);
dataFile = fname ('interpolation1D_poly1.dat');
data = load (dataFile);

X    = data(:,1);
Y    = data(:,3);
nx = length (X);

plot (X, Y, 'bo')
axis tight
grid on

# the derivative of the function generating the data changes sign 4 times.
# the polynome is then at least of degree 5. We have 11 points. We can then be
# sure that a polynome of degree 11 will interpolate the points.





e_min = 3;         # minimum exponent
e_max = e_min + 2; # maximum exponent

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
[p_est s] = polyfit (X, Y, e_simp);

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
dy = dyp (X, dp_pf, ee_simp);

#xt = linspace (min (X)*1.1, max (X)*1.1, 100).';












