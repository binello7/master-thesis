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

#clear all

load ('input_Q.dat');
load ('extracted_data.dat');

addpath ('~/Resources/gpml-matlab-v4.1-2017-10-19');
startup

## Functions

function err = f_mse (y, yp)
  err = 1 / length (y) * sum ((y - yp).^2);
endfunction





## Remove unusable experiments
i = 1;
while i <= size (H)(2)
  if weircenter_head(i) < 0.3 #0.3
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

## Trying different training data
#
xtrn = [0;hw.'];
ytrn = [0;Qin.'];

xmax = max (xtrn);
ymax = max (ytrn);


## Perform GP regression
# meanfunction
meanfunc{1} = {@meanPow,3/2,{@meanLinear}};
m{1} = 1;
meanfunc{2} = {@meanPoly,2};
m{2} = [0;0];
meanfunc{3} = {@meanPoly,3};
m{3}= [0;0;0];

#meanfunc = {@meanSum,{@meanConst,@meanLinear}};
#hyp.mean = [1;1];
#meanfunc = {@meanLinear};
#hyp.mean = 1;

# covariance function
#covfunc = @covNoise;
#hyp.cov = 0; # log(sf)
covfunc = @covZero;
cov_a = [];
#covfunc = {@covSEvlen,{@meanLinear}};
#hyp.cov = [1;0];


# likelihood function
likfunc = @likGauss;
lik_a = 0;

for i = 1:3
  hyp{i}.mean = m{i};
  hyp{i}.cov = cov_a;
  hyp{i}.lik = lik_a;
endfor

args = {covfunc, likfunc, xtrn, ytrn};

for i = 1:3
  hyp{i} = minimize (hyp{i}, @gp, -1000, @infExact, meanfunc{i}, args{:});
endfor

xp = [linspace(0, xmax, 200)].';

for i = 1:3
  yp{i} = gp (hyp{i}, @infExact, meanfunc{i}, args{:}, xp);
endfor

figure (f)
f+=1;
plot (ytrn, xtrn, 'ok'),
hold on
col = {'b', 'r', 'g'};

for i = 1:3
  plot (yp{i}, xp, col{i})
endfor
hold off
legend ('training dataset', 'weir eqn.', 'poly. deg.2', 'poly. deg.3')
#axis ([0 xmax 0 ymax]);

## Compute the error
rand_idx = randperm (length (xtrn))(1:8)
xtrn_short = xtrn(rand_idx);
ytrn_short = ytrn(rand_idx);

for k = 1:3
  hyperr{k}.mean = hyp{k}.mean;
  hyperr{k}.cov = hyp{k}.cov;
  hyperr{k}.lik = hyp{k}.lik;
endfor

n = length (xtrn_short);
indexes = 1:n;
for i = 1:n-2
  idx_off = nchoosek (indexes,i);
  for j = 1:size(idx_off)(1)
    printf ('%d of %d\n', j, nchoosek (n,i))
    idx_trn = logical (ones (1,n));
    idx_trn(idx_off(j,:)) = 0;
    xe_trn = xtrn_short(idx_trn);
    ye_trn = ytrn_short(idx_trn);
    xe_tst = xtrn_short(!idx_trn);
    ye_tst = ytrn_short(!idx_trn);
    for k = 1:3
      hyperr{k} = minimize (hyperr{k}, @gp, -1000, @infExact, meanfunc{k}, covfunc, likfunc, xe_trn, ye_trn);
      ye_pred{k} = gp (hyperr{k}, @infExact, meanfunc{k}, covfunc, likfunc, xe_trn, ye_trn, xe_tst);
      mse{j,k,i} = f_mse (ye_pred{k}, ye_tst);
    end
  endfor
endfor

for i=1:size (mse)(3)
  for j=1:size (mse)(2)
    mean_mse(i,j) = mean (cell2mat (mse(:,j,i)),1);
  endfor
endfor





