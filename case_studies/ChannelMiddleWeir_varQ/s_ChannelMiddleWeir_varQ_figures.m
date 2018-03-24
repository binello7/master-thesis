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

## Extract useful parameters
params = read_params ('Inputs/parameters_01.txt');
Nx      = params.Nxcell;
Ny      = params.Nycell;
nstates = params.nbtimes;

## Treat topography data
X = topography(:,1);
Y = topography(:,2);
Z = topography(:,3);

[X Y Z] = dataconvert ('octave', [Nx Ny], X, Y, Z);



## Treat water height data
if ~exist ('H', 'var')
  load ('Outputs_21/huz_evolution.dat');
  h = huz_evolution(:,6);
  H = zeros (Ny, Nx, nstates);

  for t = 1:nstates
      idx_1 = 1 + (t - 1) * Nx * Ny;
      idx_2 = t * Nx * Ny;
      span = idx_1:idx_2;
      H(:,:,t) = dataconvert ('octave', [Nx Ny], h(span));
  endfor
endif


if bool_plots{1,2}
  rgb_max = 255;
  c1 = [96 96 96]/rgb_max;
  c2 = [192 192 192]/rgb_max;
  bm = [31 73 145]/rgb_max;
  tp = 16;
  h1 = surf (X, Y, Z, 'facecolor', c2, 'edgecolor', c1, 'linewidth', 0.2);
  hold on
  h2 = mesh (X, Y, H(:,:,tp), 'edgecolor', bm);
  set (h2, 'facecolor', 'none');
  hold off
  set (gca, 'xtick', [0 2 4], 'xticklabel', {'0' '2' '4'}, ...
       'ztick', [0 1 2 3], 'zticklabel', {'0' '1' '2' '3'});
  axis equal
  axis ([0 4 0 40 0 max(H(:,:,tp)(:))])
  axis tight
  grid off
  view (-32,22)

  xlabel ('x [m]')
  ylabel ('y [m]')
  zlabel ('z [m]')
  print ('channel.png', '-r600')
endif

