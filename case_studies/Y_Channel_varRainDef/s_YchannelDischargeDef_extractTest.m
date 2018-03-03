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
## Created: 2018-02-06

clear all
pkg load fswof2d

## Load data
#
load ('rain_intensities_test.dat');
load ('soil_saturations_test.dat');
load ('parameters.dat');


nri = length (rain_intensities_test);
nss = length (soil_saturations_test);

j = 1;
tic
for i = 1:nri
  for s = 1:nss
    for n = 1:saved_states
      folderSuff    = sprintf ('_t%01d%01d', s, i);
      outputsFolder = strcat ('Outputs', folderSuff);
      q_temp = dlmread (fullfile (outputsFolder, 'huz_evolution.dat'), ...
        '\tab', [(n-1)*(Nx*Ny+Nx+3)+6 11 (n-1)*(Nx*Ny+Nx+3)+5+Nx*Ny 11]);
      qq_temp = dataconvert ('octave', [Nx Ny], q_temp);
      qt_bbound_test(j,n)   = sum (qq_temp(1,:));
    endfor
    j +=1;
  endfor
endfor
toc

save ('qt_bbound_test.dat', 'qt_bbound_test');

