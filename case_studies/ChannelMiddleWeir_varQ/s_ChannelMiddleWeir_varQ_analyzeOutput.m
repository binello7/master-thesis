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
pkg load optim

## Load the variables
# load variables if not present in workspace
load ('input_Q.dat');
load ('extracted_data.dat');

#i = 1;
## Remove unusable experiments
#while i <= size (H)(2)
#  if weircenter_head(i) < 0.05
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

## Input data
Qin   = abs (Qin);
Qt    = linspace (0, 10, 100);
H_max = H_max - weir_height;
h0    = h0 - weir_height;

## Functions
hweir    = @(Q, p) (Q / (2 /3 * p(1) * sqrt (2*9.81) * B)).^(p(2));
hweir_ca = @(Q, p) (Q / (2 /3 * p * sqrt (2*9.81) * B)).^(2/3);
iswater  = @(z,h,tol) abs(z-h)>tol;
water    = @(z,h,tol=5e-3)ifelse(iswater(z,h,tol), h, NA);


## Perform linear regression
# method 1
lQin = (log10 (Qin)).';
lh0  = (log10 (h0)).';
n   = length (lh0);

## C: exponent of the weir equation (usually 2/3 - 3/2, depending if Q(h) or h(Q))l
#C1  = 10^(mean (lQin - 3/2 * lh0));
#mu1 = C1 / (2/3 * B * sqrt(2 * 9.81));


#Lh0 = [ones(n, 1) lh0];

## compute theta
#theta = (pinv(Lh0.'*Lh0))*Lh0.'*lQin;
#C2    = 10^theta(1);
#mu2   = C2 / (2/3 * B * sqrt(2 * 9.81));
#a     = theta(2);

## Perform linear regression
# method 2 - a = 2/3
[Fca, Pca, CVGca, ITERca, CORPca, COVPca, COVRca, STDRESIDca, Zca, R2ca] = leasqr (Qin.', h0.', 0.6, hweir_ca);

# method 2 - regression on a as well
[Fra, Pra, CVGra, ITERra, CORPra, COVPra, COVRra, STDRESIDra, Zra, R2ra] = leasqr (Qin.', h0.', [0.6 2/3], hweir);


MSE(1) = 1/n * sum ((h0 - hweir (Qin, [0.57; 2/3])).^2);
MSE(2) = 1/n * sum ((h0 - hweir_ca (Qin, Pca)).^2);
MSE(3) = 1/n * sum ((h0 - hweir (Qin, Pra)).^2);





## Pre-analysis
# plot of log(data)
figure (1)
plot (lh0, lQin, 'o')


## Generate the plots
# plot 1: longitudinal profile for the 25 experiments
i1 = 150; i2 = 240;
plt_span_Y = i1:i2;
plt_span_Z = i2:-1:i1;
#plt_span_Y = 1:length (Y);
#plt_span_Z = length (Y):-1:1;
figure (2)
plot (Y(plt_span_Y), Z(plt_span_Z), '-k', 'linewidth', 3);
hold on
plot (Y(plt_span_Y), water (Z(plt_span_Z), HZ(plt_span_Z,:)));
hold off
axis equal
xlabel ('Ly [m]');
ylabel ('h [m]')
annotation ('textarrow', [0.4 0.45], [0.8 0.8], 'string', ' flow direction', ...
            'color', 'b', 'headlength', 6, 'headwidth', 6)

print ('free_surfaces.eps', '-color');
print ('free_surfaces.png', '-r300');

# plot 2: Q - h relation for the 25 experiments
figure (3)
plot (Qin, h0, 'ko', Qt, hweir (Qt, [0.57, 2/3]), 'b', ...
      Qt, hweir (Qt, [Pca, 2/3]), 'g', Qt, hweir (Qt, [Pra(1) Pra(2)]), 'r')
xlabel ('Q [m^3/s]')
ylabel ('h_{w} [m]')

legend ('simulated values', '1: trial-error fitting \mu = 0.570', ...
        sprintf ('2: regression on \\mu, \\mu = %0.3f', Pca), ...
        sprintf ('3: regression on \\mu and a, \\mu = %0.3f, a = %0.2f', Pra(1), 1/Pra(2)), 'location', 'northwest')

print ('points_interpolations.eps', '-color');
print ('points_interpolations.png', '-r300');



