## Copyright (C) 2018 Sebastiano Rusca
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##g
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.
##
## Author: Sebastiano Rusca <sebastiano.rusca@gmail.com>
## Created: 2018-03-08

clear all

load ('input_Q.dat');
load ('extracted_data.dat');

addpath ('~/Resources/gpml-matlab-v4.1-2017-10-19');
startup


## Remove unusable experiments
i = 1;
while i <= size (H)(2)
  if weircenter_head(i) < 0.1 #0.3
    weircenter_head(i) = [];
    Qin(i)             = [];
    H(:,i)             = [];
    HZ(:,i)            = [];
    H_max(i)           = [];
    h0(i)              = [];
    v0(i)              = [];
  endif
  i+=1;
endwhile


f = 1; # figure number

# Transform the data
Qin = sort (abs(Qin));
hw = sort (h0 - weir_height);

### Visualize the data
#figure (f)
#f+=1;
#plot (Qin, hw, 'ok')
#axis ([0 max(Qin) 0 max(hw)]);

## Trying different training data
#
#idx = 14;
#xtrn = Qin(idx);
#ytrn = hw(idx);


x = [10^-5;Qin.'];#0];
y = [10^-5;hw.'];#0];
xmax = max (x);
ymax = max (y);


xtrn = log10 (x);
ytrn = log10 (y);
#xtrn = x;
#ytrn = y;




## Perform GP regression
# meanfunction
#meanfunc = {@meanPow,3/2,{@meanLinear}};
#hyp.mean = 1;
#meanfunc = {@meanPoly,2};
#hyp.mean = [0;0];
meanfunc = {@meanSum,{@meanConst,@meanLinear}};
hyp.mean = [1;1];


# covariance function
#covfunc = @covNoise;
#hyp.cov = 0;
#covfunc = @covZero;
#hyp.cov = [];
covfunc = {@covSEvlen,{@meanLinear}};
hyp.cov = [1;0];


# likelihood function
likfunc = @likGauss;
hyp.lik = 0;


hyp = minimize (hyp, @gp, -1000, @infExact, meanfunc, covfunc, likfunc, xtrn, ytrn);

xp = [linspace(10^-5, xmax, 200)].';
xp = log10 (xp);

[yp s2] = gp (hyp, @infExact, meanfunc, covfunc, likfunc, xtrn, ytrn, xp);

#xo_plot = xtrn;
#yo_plot = ytrn;
#xl_plot = xp;
#yl_plot = yp;
xo_plot = 10.^xtrn;
yo_plot = 10.^ytrn;
xl_plot = 10.^xp;
yl_plot = 10.^yp;

figure (f)
f+=1;
plot (xo_plot, yo_plot, 'ok', xl_plot, yl_plot, '-b')
#axis ([0 xmax 0 ymax]);

feval(covfunc{:},hyp.cov,xtrn)



