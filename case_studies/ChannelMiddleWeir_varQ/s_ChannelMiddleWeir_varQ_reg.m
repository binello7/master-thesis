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

#addpath ('~/Resources/gpml-matlab-v4.1-2017-10-19');
#startup

## Functions
f_Qw = @(C,h,a) C*h.^a;

function err = f_rmse (y, yp)
  err = sqrt (1 / length (y) * sum ((y - yp).^2));
endfunction

function err = f_mae (y, yp)
  err = max (abs (y - yp));
endfunction

function theta = lin_reg (x,y)
  n = length (x);
  X = [ones(n,1) x];
  theta = (pinv(X.'*X))*X.'*y;
endfunction



# Remove unusable experiments
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


# Transform the data
Qin = sort (abs(Qin));
hw = sort (h0 - weir_height);

## Define training data
#
xtrn = [0.01;hw.'];#0.01
ytrn = [0.0044;Qin.'];#0.0044
#xtrn = xtrn + 0.01*rand(size(xtrn));
#ytrn = ytrn +0.01*rand(size(xtrn));

xmax = max (xtrn);
ymax = max (ytrn);

# linearize the data
lxtrn = log10 (xtrn);
lytrn = log10 (ytrn);

## Perform linear regression
theta = lin_reg (lxtrn, lytrn);
C = 10^theta(1);
a = theta(2);
mu = C / (2/3 * B * sqrt(2*9.81));


# define evaluation points
xp = linspace (0, xmax+0.1*xmax, 200);
yp = zeros (length (xp), 3);

# evaluate linear regression on xp
yp(:,1) = f_Qw(C,xp,a);

# perform linear and spline interpolations
yp(:,2) = interp1 (xtrn, ytrn, xp, 'linear', 'extrap');
yp(:,3) = interp1 (xtrn, ytrn, xp, 'spline', 'extrap');


## Compute cross-validation error
#
idx_short = [1 3 4 5 6 9 11 12 15 16 19 18 21 length(xtrn)];
xtrn_short = xtrn(idx_short);
ytrn_short = ytrn(idx_short);
lxtrn_short = lxtrn(idx_short);
lytrn_short = lytrn(idx_short);

n1 = length (xtrn_short);
indexes = 2:n1-1;
n2 = length (indexes);
for i = 1:n2-2
  idx_off = nchoosek (indexes,i);
  for j = 1:size(idx_off)(1)
#    printf ('%d of %d\n', j, nchoosek (n2,i))
    idx_trn = logical (ones (1,n1));
    idx_trn(idx_off(j,:)) = 0;
    xe_trn = xtrn_short(idx_trn);
    ye_trn = ytrn_short(idx_trn);
    xe_tst = xtrn_short(!idx_trn);
    ye_tst = ytrn_short(!idx_trn);
    lxe_trn = lxtrn_short(idx_trn);
    lye_trn = lytrn_short(idx_trn);
    theta_e = lin_reg (lxe_trn, lye_trn);
    C_e = 10^theta_e(1);
    a_e = theta_e(2);
    ye_pred{1} = f_Qw (C_e, xe_tst, a_e);
    ye_pred{2} = interp1 (xe_trn, ye_trn, xe_tst, 'linear');
    ye_pred{3} = interp1 (xe_trn, ye_trn, xe_tst, 'spline');
    for k = 1:3
      rmse{j,k,i} = f_rmse (ye_pred{k}, ye_tst);
      mae{j,k,i} = f_mae (ye_pred{k}, ye_tst);
    endfor
  endfor
endfor

for i=1:size (rmse)(3)
  for j=1:size (rmse)(2)
    mean_rmse(i,j) = mean (cell2mat (rmse(:,j,i)),1);
    max_mae(i,j) = max (cell2mat (mae(:,j,i)),[],1);
  endfor
endfor

save ('data_RMSE.dat', 'mean_rmse');


## Plot the results
# plot 1: different fittings all data
f = 1;
figure (f)
f+=1;
plot (ytrn, xtrn, 'ok')
col = {'b', 'r', 'g'};

hold on
for i = 1:3
  plot (yp(:,i), xp, col{i});
endfor
hold off

legend ('training dataset', sprintf ('weir equation\n(\\mu = %0.2f, a = %0.2f)', mu, a), 'linear fit', 'spline fit', 'location', 'northwest')
axis tight;
xlabel ('Q [m^3/s]');
ylabel ('h_w [m]')
print ('fitting_results.png', '-r300')


# plot 2: fitting errors
mean_rmse_cm = 100 * mean_rmse; # convert error in cm
figure (f)
f+=1;
semilogy (mean_rmse_cm, col)
axis tight;
legend ('weir equation', 'linear fit', 'spline fit', 'location', 'northwest')
xlabel ('left-out points')
ylabel ('RMSE [cm]')

xtickn = 1:length (mean_rmse);
xtickl = num2cell (xtickn);
for i = 1:length(mean_rmse)
  xtickl{i} = num2str(xtickl{i});
endfor

set (gca, 'xtick', xtickn, 'xticklabel', xtickl);
print ('fitting_errors.png', '-r300')



# ------------------------------------------------------------------------------
## Perform GP regression
# meanfunction
#meanfunc{1} = {@meanPow,3/2,{@meanLinear}};
#m{1} = 1;
#meanfunc{2} = {@meanPoly,2};
#m{2} = [0;0];
#meanfunc{3} = {@meanPoly,3};
#m{3}= [0;0;0];

#meanfunc = {@meanSum,{@meanConst,@meanLinear}};
#hyp.mean = [1;1];
#meanfunc = {@meanLinear};
#hyp.mean = 1;

# covariance function
#covfunc = @covNoise;
#hyp.cov = 0; # log(sf)
#covfunc = @covZero;
#cov_a = [];
#covfunc = {@covSEvlen,{@meanLinear}};
#hyp.cov = [1;0];


# likelihood function
#likfunc = @likGauss;
#lik_a = 0;

#for i = 1:3
#  hyp{i}.mean = m{i};
#  hyp{i}.cov = cov_a;
#  hyp{i}.lik = lik_a;
#endfor

#args = {covfunc, likfunc, xtrn, ytrn};

#for i = 1:3
#  hyp{i} = minimize (hyp{i}, @gp, -1000, @infExact, meanfunc{i}, args{:});
#endfor

#xp = [linspace(0, xmax, 200)].';

#for i = 1:3
#  yp{i} = gp (hyp{i}, @infExact, meanfunc{i}, args{:}, xp);
#endfor



### Compute the error
##rand_idx = randperm (length (xtrn))(1:8)
#idx_short = [1 3 4 5 6 9 11 12 15 16 19 18 21 length(xtrn)];
#xtrn_short = xtrn(idx_short);
#ytrn_short = ytrn(idx_short);

##for k = 1:3
##  hyperr{k}.mean = hyp{k}.mean;
##  hyperr{k}.cov = hyp{k}.cov;
##  hyperr{k}.lik = hyp{k}.lik;
##endfor

#n = length (xtrn_short);
#indexes = 1:n;
#for i = 1:n-2
#  idx_off = nchoosek (indexes,i);
#  for j = 1:size(idx_off)(1)
#    printf ('%d of %d\n', j, nchoosek (n,i))
#    idx_trn = logical (ones (1,n));
#    idx_trn(idx_off(j,:)) = 0;
#    xe_trn = xtrn_short(idx_trn);
#    ye_trn = ytrn_short(idx_trn);
#    xe_tst = xtrn_short(!idx_trn);
#    ye_tst = ytrn_short(!idx_trn);
#    for k = 1:3
#      hyperr{k} = minimize (hyperr{k}, @gp, -1000, @infExact, meanfunc{k}, covfunc, likfunc, xe_trn, ye_trn);
#      ye_pred{k} = gp (hyperr{k}, @infExact, meanfunc{k}, covfunc, likfunc, xe_trn, ye_trn, xe_tst);
#      mse{j,k,i} = f_mse (ye_pred{k}, ye_tst);
#    end
#  endfor
#endfor

#for i=1:size (mse)(3)
#  for j=1:size (mse)(2)
#    mean_mse(i,j) = mean (cell2mat (mse(:,j,i)),1);
#  endfor
#endfor





