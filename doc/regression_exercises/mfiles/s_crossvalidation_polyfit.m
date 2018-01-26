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
dataFolder = 'data';
fname = @(s) fullfile ('..', dataFolder, s);
mse   = @(y, yf) 1 / length (y) * sum ((y - yf).^2);


dataFile = fname ('interpolation1D_poly1.dat');

data = load (dataFile);

X = data(:,1);
Y = data(:,2);

plot (X, Y, 'bo')
axis tight

nx = length (X);
MaxIter = 1e3;
n_max = floor (MaxIter / nx);                  # maximum number of exponents sets
e_max = floor (log (n_max + 1) / log (2) - 1); # maximum exponent

##
# every exponent can be considered (1) or not (0). If the exponent max is 3
# then we have 4 coefficients (^0 also to be considered). The case [0 0 0 0] is
# of course not considered.
n_sets = 2^(e_max + 1) - 1;

e_sets = dec2bin (1:n_sets) =='1';


for i = 1:n_sets;
  p_est(i,:) = polyfit (X, Y, e_sets(i,:));
  mse_e(i,1) = mse(Y, polyval (p_est(i,:), X));
endfor



