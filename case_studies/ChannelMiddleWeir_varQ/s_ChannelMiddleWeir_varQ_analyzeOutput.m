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
## Created: 2018-01-21

close all

## Load the variables
# load variables if not present in workspace
load ('input_Q.dat');
load ('extracted_data.dat');

#i = 1;
### Remove unusable experiments
#while i <= size (H)(2)
#  if weircenter_head(i) < 0.3
#    weircenter_head(i) = [];
#    Qin(i)             = [];
#    H(:,i)             = [];
#    HZ(:,i)            = [];
#    H_max(i)           = [];
#    h0(i)              = [];
#    v0(i)              = [];
#  endif
#  i+=1;
#endwhile


Qin   = abs (Qin);
Q_reg = linspace (0, 10, 50);
H_max = H_max - weir_height;
h0    = h0 - weir_height;

hweir = @(Q, mu, c) (Q / (2 /3 * mu * sqrt (2*9.81) * B)).^(c);
iswater=@(z,h,tol) abs(z-h)>tol;
water=@(z,h,tol=5e-3)ifelse(iswater(z,h,tol), h, NA);


## Perform linear regression
#
lQin = (log10 (Qin)).';
lh0  = (log10 (h0)).';

C1  = 10^(mean (lQin - 3/2 * lh0));
mu1 = C1 / (2/3 * B * sqrt(2 * 9.81));

n   = length (lh0);
Lh0 = [ones(n, 1) lh0];

# compute theta
theta = (pinv(Lh0.'*Lh0))*Lh0.'*lQin;
C2    = 10^theta(1);
mu2   = C2 / (2/3 * B * sqrt(2 * 9.81));
a     = theta(2);

MSE(1) = 1/n * sum ((h0 - hweir(Qin, 0.57, 2/3)).^2);
MSE(2) = 1/n * sum ((h0 - hweir(Qin, mu1, 2/3)).^2);
MSE(3) = 1/n * sum ((h0 - hweir(Qin, mu2, 1/a)).^2);



figure (1)
plot (lh0, lQin, 'o')
hold on
plot (log10 (hweir(Qin, mu2, 1/a)), lQin, 'ro')
hold off

## Generate the plots of the analyzed variables
# plot 1: longitudinal profile for the 25 experiments
plt_span = 150:250;
figure (2)
plot (Y(plt_span), Z(plt_span), '-k', 'linewidth', 3);
hold on
plot (Y(plt_span), water (Z(plt_span), HZ(plt_span,:)));
hold off
axis equal
title ('Free surface profiles for Q in range 1 - 10 m3/s')
xlabel ('Ly [m]');
ylabel ('h [m]')
annotation ('textarrow', [0.7 0.65], [0.8 0.8], 'string', ' flow direction', ...
            'color', 'b', 'headlength', 6, 'headwidth', 6)
print ('free_surfaces.eps', '-color');

# plot 2: Q - h relation for the 25 experiments
figure (3)
plot (Qin, h0, 'ko', Q_reg, hweir(Q_reg, 0.57, 2/3), 'b',
      Q_reg, hweir(Q_reg, mu1, 2/3), 'g', Q_reg, hweir(Q_reg, mu2, 1/a), 'r')
xlabel ('Q [m^3/s]')
ylabel ('h_{w} [m]')
legend ('simulated values', '1: trial-error fitting \mu = 0.57',
        '2: regression on \mu, \mu = 0.553', '3: regression on \mu and a, \mu = 0.560, a =  1.59', 'location', 'northwest')
print ('points_interpolations.eps', '-color');

# plot XX: logQ - logh relation for the 25 experiments
#figure (4)
#loglog (Qin, weircenter_head, 'ro')







