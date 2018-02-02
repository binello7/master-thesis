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
nst = length (soil_saturations);
ntot = nrd * nri * nst;

#nrd = 1;
#nri = 1;
#nst = 1;
#i = 3;
#d = 3;
#s = 2;

j = 1;
for i = 1:nri
  for d = 1:nrd
    for s = 1:nst
      folderSuff    = sprintf ('_%01d_%02d%02d', s, i, d);
      outputsFolder = strcat ('Outputs', folderSuff);
      load (fullfile (outputsFolder, 'huz_evolution.dat'));
      q_evl = huz_evolution(:,12);
      qqq = evolution_matrix (Nx, Ny, saved_states(d),q_evl);
      clear q_evl;
      qt_lbound{j} = sum (qqq(1,:,:), 2)(:);
      indexes(j,:) = [s i d];
      j +=1;
    endfor
  endfor
endfor

indexes = dataframe (indexes(:,1), indexes(:,2), indexes(:,3), 'colnames', {'s', 'i', 'd'});







