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
## Created: 2018-02-02

clear all
pkg load fswof2d
pkg load dataframe

## Load data
#
load (fullfile ('Inputs', 'topography.dat'));
load ('rain_durations.dat');
load ('rain_intensities.dat');
load ('sim_durations.dat');
load ('soil_saturations.dat');
load ('parameters.dat');

[XX YY ZZ] = dataconvert ('octave', [Nx Ny], topography(:,1), topography(:,2), topography(:,3));
clear topography;


nrd = length (rain_durations);
nri = length (rain_intensities);
nsat = length (soil_saturations);
ntot = nrd * nri * nsat;

#nrd = 1;
#nri = 1;
#nsat = 1;
i = 3;
d = 3;
s = 2;

j = 1;
tic
#for i = 1:nri
#  for d = 1:nrd
#    for s = 1:nsat
      for n = 1:saved_states(d)
        folderSuff    = sprintf ('_%01d_%02d%02d', s, i, d);
        outputsFolder = strcat ('Outputs', folderSuff);
        q_temp = dlmread (fullfile (outputsFolder, 'huz_evolution.dat'), '\tab', [(n-1)*(Nx*Ny+Nx+3)+6 11 (n-1)*(Nx*Ny+Nx+3)+5+Nx*Ny 11]);
        qq_temp = dataconvert ('octave', [Nx Ny], q_temp);
        qt_bbound{j} = sum (qq_temp(1,:));
        indexes(j,:) = [s i d];
      endfor
      j +=1;
#    endfor
#  endfor
#endfor
toc

save ('qt_bbound.dat', 'qt_bbound');


indexes_table = dataframe (indexes(:,1), indexes(:,2), indexes(:,3), 'colnames', {'s', 'i', 'd'});
save ('indexes_table.dat', 'indexes_table');






