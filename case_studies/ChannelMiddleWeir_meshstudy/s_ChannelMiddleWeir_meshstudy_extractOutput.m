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

## Global parameters
#
dataFolder  = 'data';
studyName   = 'ChannelMiddleWeir_meshstudy_2';

## Variables to save to the outputfile
#
vars = {'XX', 'YY', 'ZZ', 'HH', 'HHz', 'FFr', 'VVn', 'nExp', ...
       'Nx', 'Ny', 'Ly', 'metadata'};
metadata.XX = 'Matrix of the x-nodes coordinates';
metadata.YY = 'Matrix of the y-nodes coordinates';
metadata.ZZ = 'Matrix of the z-nodes coordinates';

## Generate path of needed files
studyFolder          = fullfile (dataFolder, studyName);
inputsFolder         = fullfile (studyFolder, 'Inputs');
load (fullfile (studyFolder, 'input_variables.dat'));
nExp                 = size (ls ('-d', fullfile (studyFolder, 'Outputs_*')))(1);

## Extract data from files and convert them to 'octave format'
for i = 1:nExp
  outputsFolder = fullfile (studyFolder, sprintf ('Outputs_%02d', i));
  loadfile      = @(s) load (fullfile (outputsFolder, s));
  data_init     = loadfile ('huz_initial.dat');
  data_evl      = loadfile ('huz_evolution.dat');
  paramsfile    = fullfile (inputsFolder, sprintf ('parameters_%02d.dat', i));
  params{i}     = read_params (paramsfile);
  Nx(i) = params{i}.Nxcell;
  Ny(i) = params{i}.Nycell;
  Ly    = params{1}.l;
  X{i}  = data_init(:,1);
  Y{i}  = data_init(:,2);
  Z{i}  = data_init(:,7);
  H{i}  = data_evl(:,3);
  Hz{i} = data_evl(:,6);
  Fr{i} = data_evl(:,9);
  Vn{i} = data_evl(:,8);
  clear data_init;
  clear data_evl;
  
  [XX{i} YY{i} ZZ{i}] = dataconvert ('octave', [Nx(i) Ny(i)], X{i}, Y{i}, Z{i});
  
  nstates = params{i}.nbtimes;
  for t = 1:nstates
    idx_1 = 1 + (t - 1) * Nx(i) * Ny(i);
    idx_2 = t * Nx(i) * Ny(i);
    span = idx_1:idx_2;

    [HH{i}(:,:,t) HHz{i}(:,:,t) FFr{i}(:,:,t) VVn{i}(:,:,t)] = ...
    dataconvert ('octave', [Nx(i) Ny(i)], ...
    H{i}(span), Hz{i}(span), Fr{i}(span), Vn{i}(span));
  endfor

endfor

clear X Y Z H Hz Fr Vn
save (fullfile (studyFolder, 'extracted_data.dat'), vars{:});
save (fullfile (studyFolder, 'metadata.dat'), 'metadata');

