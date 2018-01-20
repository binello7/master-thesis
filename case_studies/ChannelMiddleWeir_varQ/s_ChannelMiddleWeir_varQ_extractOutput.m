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
## Created: 2018-01-09

pkg load fswof2d


## Variables to save to the outputfile
#
vars = {'Y', 'Z', 'H', 'middleweir_head', 'HZ', 'H_max', 'Y_max', 'nExp', ...
       'Nx', 'Ny', 'dx', 'dy', 'B', 'Ly', 'metadata'};

metadata.XX = 'Matrix of the x-nodes coordinates';
metadata.YY = 'Matrix of the y-nodes coordinates';
metadata.ZZ = 'Matrix of the z-nodes coordinates';

## Generate path of needed files
#
inputsFolder    = 'Inputs';
nExp            = size (ls ('-d', 'Outputs_*'))(1);
load 'input_variables.dat';

## Extract data from files and convert them to 'octave format'
#
weir_mes_pos = (wTop_l + wTop_r) / 2;
middleweir_head         = zeros (1, nExp);

for i = 1:nExp
  outputsFolder = sprintf ('Outputs_%02d', i);
  loadfile      = @(s) load (fullfile (outputsFolder, s));
  data_init     = loadfile ('huz_initial.dat');
  data_evl      = loadfile ('huz_evolution.dat');
  paramsfile    = fullfile (inputsFolder, sprintf ('parameters_%02d.dat', i));
  params{i}     = read_params (paramsfile);
  Nx(i) = params{i}.Nxcell;
  Ny(i) = params{i}.Nycell;
  B     = params{1}.L;
  Ly    = params{1}.l;
  Y{i}  = data_init(1:Ny(i),2);
  Z{i}  = data_init(1:Ny(i),7);
  clear data_init;
  h{i}  = data_evl(:,3);
  clear data_evl;

  nstates = params{i}.nbtimes;

  for t = 1:nstates
    idx_1 = 1 + (t - 1) * Nx(i) * Ny(i);
    idx_2 = t * Nx(i) * Ny(i);
    span = idx_1:idx_2;
    HH{i}(:,:,t) = dataconvert ('octave', [Nx(i) Ny(i)], h{i}(span));
  endfor

  H{i} = mean (HH{i}(:, round (end/2), 100:end), 3);
  [H_max(i), max_idx(i)] = max (H{i});
  HZ{i} = H{i} + Z{i};
  middleweir_head(i) = interp1 (Y{i}, H{i}, weir_mes_pos);
endfor

dx = B ./ Nx;
dy = Ly ./ Ny;

Y_max = (max_idx - 1) .* dy .+ 0.5 * dy;

clear h HH idx_1 idx_2 span params paramsfile


save ('extracted_data.dat', vars{:});
save ('metadata.dat', 'metadata');

