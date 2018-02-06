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

## Load data
#
load ('qt_bbound_mat.dat');
load ('soil_saturations.dat');
load ('rain_intensities.dat');
load ('parameters.dat');

rain_intensities = rain_intensities * 1000 * 3600; #[mm/h]

nExp = length (qt_bbound);
nInt = length (rain_intensities);
nSat = length (soil_saturations);

Q_trhsh = 0.6; #[m3/s];

idx_thrsh = zeros (nSat, nInt);
for i = 1:nInt
  for s = 1:nSat
    [Qmax(s,i) idx_max(s,i)] = max (qt_bbound(:,i,s));
    if isempty (find (qt_bbound(:,i,s) >= Q_trhsh, 1))
      idx_thrsh(s,i) = 0;
    else
      idx_thrsh(s,i) = find (qt_bbound(:,i,s) >= Q_trhsh, 1);
    endif
  endfor
endfor


t_Qthrsh   = idx_thrsh * dt; #[s]
t_Qthrsh = t_Qthrsh / 60; #[min]


for i = 1:nInt
  if isempty (find (t_Qthrsh(:,i) == 0)) && isempty (find (t_Qthrsh(1,i:end) == 0))
    temp = t_Qthrsh(:,i:end);
    break;
  endif
endfor
t_Qthrsh = temp;
clear temp;

sat_train = soil_saturations.';
ri_train  = rain_intensities(i:end);





### Extract training data for building the emulator
## method: meshgrid
#[j,k]    = find (t_Qthrsh);

#ri_emu(:,1)  = rain_intensities(k(:));
#sat_emu(:,1) = soil_saturations(j(:));
#t_Qthrsh     = nonzeros (t_Qthrsh);
