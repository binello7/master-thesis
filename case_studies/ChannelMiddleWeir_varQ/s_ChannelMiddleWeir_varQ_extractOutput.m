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

pkg load fswof2d


## Variables to save to the outputfile
#
vars = {'Y', 'Z', 'H', 'h0', 'v0', 'weircenter_head', 'weir_height', 'HZ', 'H_max', 'Y_max', 'nExp', ...
       'Nx', 'Ny', 'dy', 'Ly', 'B'};


## Generate path of needed files and load variables
#
inputsFolder    = 'Inputs';
topo    = load (fullfile (inputsFolder, 'topography.dat'));
params1 = read_params (fullfile (inputsFolder, 'parameters_01.txt'));
load 'input_variables.dat';

## Extract parameters common to all studies
#
Nx      = params1.Nxcell;
Ny      = params1.Nycell;
Ly      = params1.l;
B       = params1.L;
nstates = params1.nbtimes;

## Extract channel longitudinal profile and weir position
#
y = topo(:,2);
z = topo(:,3);

Y = y(1:Ny);
Z = z(1:Ny);

weir_center     = (pweir.breaks(3) + pweir.breaks(4)) / 2;

## Create variables to extract
#
nExp            = size (ls ('-d', 'Outputs_*'))(1);
weircenter_head = zeros (1, nExp);
H_max           = zeros (1, nExp);

## Extract results from each experiment
#
for i = 1:nExp
  outputsFolder = sprintf ('Outputs_%02d', i);
  loadfile      = @(s) load (fullfile (outputsFolder, s));
  data_evl      = loadfile ('huz_evolution.dat');
  h(:,i)        = data_evl(:,3);
  v(:,i)        = data_evl(:,5);
  clear data_evl;

  for t = 1:nstates
    idx_1 = 1 + (t - 1) * Nx * Ny;
    idx_2 = t * Nx * Ny;
    span = idx_1:idx_2;
    [HH{i}(:,:,t) VV{i}(:,:,t)] = dataconvert ('octave', [Nx Ny], ...
                                               h(span,i), v(span,i));
  endfor

  H(:,i) = mean (HH{i}(:, round (end/2), 100:end), 3);
  h0(i)  = mean (mean (HH{i}(240, :, 100:end), 3), 2);
  v0(i)  = mean (mean (VV{i}(240, :, 100:end), 3), 2);
  [H_max(i), max_idx(i)] = max (H(:,i));
  HZ(:,i) = H(:,i) + Z;
  weircenter_head(i) = interp1 (Y, H(:,i), weir_center);
endfor

dy = Ly / Ny;
Y_max = (max_idx - 0.5) * dy;

clear h HH idx_1 idx_2 span params1

save ('extracted_data.dat', vars{:});

