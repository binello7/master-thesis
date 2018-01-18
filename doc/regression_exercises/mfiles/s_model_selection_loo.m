# Copyright (C) 2018 Juan Pablo Carbajal
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

# Author: Juan Pablo Carbajal <ajuanpi+dev@gmail.com>
# Created: 2018-01-17

## Polynomial model selection
#

##
# A simple function that generates all leave-one-out subsets
ind_loo = @(nx) ! logical (eye (nx));

##
# Simple functions to do LOO
se_o_f  = @(xy,xyt,n) (polyval ( polyfit (xy(:,1), xy(:,2), n), xyt(:,1)) - xyt(:,2)).^2;
mse_o_f = @(xy, loo, n) mean(arrayfun (@(i)se_o_f(xy(loo(i,:),:), xy(!loo(i,:),:), n), 1:size(loo,1)));

## Data
#
nx  = 35;
x   = [(2*rand(nx, 1)-1); -1; 1]*1.1;
nx  = length (x);
ind = ind_loo (nx);

p_true = [-4 0 0 4 5 1];
y      = polyval(p_true, x);
yn     = y + 0.1 * randn (nx, 1);

##
# Generate all possible exponents
MaxIter = 1e4;
n_max = floor (MaxIter / nx);                  # maximum number of exponents sets
o_max = floor (log (n_max + 1) / log (2) - 1); # maximum exponent
n_max = 2^(o_max + 1) - 1;

tic;
n = dec2bin (1:n_max, o_max+1) =='1';
xy = [x yn];
mse_o = zeros (n_max, 1);
for i = 1:n_max;
 mse_o(i) = mse_o_f (xy, ind, n(i,:));
endfor
toc;
[~,k] = min (mse_o);
no    = n(k,:);
eo    = (o_max - find (no) + 1);
[p_est s] = polyfit (x, yn, no);
dp        = sqrt (diag (s.C) / s.df)(no) * s.normr;

dyp       = @(x) sqrt (sumsq (x.^eo .* dp.', 2));

## Plots
#
xt  = linspace (min (x)*1.1, max (x)*1.1, 100).';
yt  = polyval (p_est, xt);
dyt = dyp(xt);

h = plot (x,yn,'o;data;',xt,yt,'k-;fit;', xt, polyval(p_true,xt),'g-');
axis tight
hold on
h = plot (xt, yt+dyt.*[-1 1],'r-;CI;');
hold off
xlabel ('x')
ylabel ('y');
printf ("%d ",no); printf("\n");
printf ("%d ",prepad (p_true!=0, length(no))); printf("\n\n");

printf ('%.1f(%.1f) ', [p_est(no); dp.']); printf ("\n");
printf ('%.1f ', p_true(p_true!=0)); printf ("\n");
