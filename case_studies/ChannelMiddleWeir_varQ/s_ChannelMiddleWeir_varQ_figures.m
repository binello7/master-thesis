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
## Created: 2018-03-1

#clear all

pkg load fswof2d

load ('Inputs/topography.dat');

bool_plots = {'topography', true};

## Treat topography data
params = read_params ('Inputs/parameters_01.txt');
Nx = params.Nxcell;
Ny = params.Nycell;

X = topography(:,1);
Y = topography(:,2);
Z = topography(:,3);

[X Y Z] = dataconvert ('octave', [Nx Ny], X, Y, Z);


if bool_plots{1,2}
  rgb_max = 255;
  r = 148/rgb_max;
  g = 145/rgb_max;
  b = 136/rgb_max;
  c1 = 1.5 * [r g b];
  c2 = 0.5 * c1;
  h = surf (X, Y, Z, 'facecolor', 'w', 'edgecolor', c2, 'linewidth', 0.2);
  set (gca, 'xtick', [0 2 4], 'xticklabel', {'0' '2' '4'}, ...
       'ztick', [0 1 2 3], 'zticklabel', {'0' '1' '2' '3'});
  axis ([0 4 0 40 0 3])
  axis equal
  view (-32,22)
  print ('channel.png', '-r600')
  xlabel ('x [m]')
  ylabel ('y [m]')
  zlabel ('z [m]')
endif

