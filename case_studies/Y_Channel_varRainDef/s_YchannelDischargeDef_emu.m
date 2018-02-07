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
load ('qt_bbound_test.dat');
load ('qt_bbound_val.dat');
load ('soil_saturations.dat');
load ('soil_saturations_test.dat');
load ('soil_saturations_val.dat');
load ('rain_intensities.dat');
load ('rain_intensities_test.dat');
load ('rain_intensities_val.dat');
load ('parameters.dat');

rain_intensities = rain_intensities * 1000 * 3600; #[mm/h]
rain_intensities_test = rain_intensities_test * 1000 * 3600; #[mm/h]
rain_intensities_val = rain_intensities_val * 1000 * 3600; #[mm/h]

nExp = length (qt_bbound);
nInt = length (rain_intensities);
nSat = length (soil_saturations);


## Extract the idx of Q exceeding Q threshold
#
Q_trhsh = 0.17; #[m3/s];
idx_thrsh = zeros (nSat, nInt);
for i = 1:nInt
  for s = 1:nSat
    [Qmax(s,i) idx_max(s,i)] = max (qt_bbound(:,i,s));
    if isempty (find (qt_bbound(:,i,s) >= Q_trhsh, 1))
      idx_thrsh(s,i) = 0;
    else
      idx_thrsh(s,i) = find (qt_bbound(:,i,s) >= Q_trhsh, 1);
      idx_thrsh(s,i) = idx_thrsh(s,i) - 0.5; #threshold was exceeded between this index and the previous one -> average
    endif
  endfor
endfor

j = 1;
idx_tests = zeros(length (soil_saturations_test), length (rain_intensities_test));
for s = 1:length(soil_saturations_test)
  for i = 1:length(rain_intensities_test)
    if isempty (find (qt_bbound_test(j,:) >= Q_trhsh, 1))
      idx_test(s,i) = 0;
    else
      idx_test(i,s) = find (qt_bbound_test(j,:) >= Q_trhsh, 1);
      idx_test(i,s) = idx_test(i,s) - 0.5;
    endif
    j+=1;
  endfor
endfor

j = 1;
idx_vals = zeros(length (soil_saturations_val), length (rain_intensities_val));
for s = 1:length(soil_saturations_val)
  for i = 1:length(rain_intensities_val)
    if isempty (find (qt_bbound_val(j,:) >= Q_trhsh, 1))
      idx_val(s,i) = 0;
    else
      idx_val(s,i) = find (qt_bbound_val(j,:) >= Q_trhsh, 1);
      idx_val(s,i) = idx_val(s,i) - 0.5;
    endif
    j+=1;
  endfor
endfor



# converting the index in time
t_Qtrain_0   = idx_thrsh * dt / 60; #[min]
t_Qtest = idx_test * dt / 60; #[min]
t_Qval = idx_val * dt / 60; #[min]
#t_Qtrain_na = t_Qtrain_0;
#t_Qtrain_na(t_Qtrain_0==0) = NA;
#t_Qtest    = idx_test * dt / 60; #[min]


## extract the bigger regular grid to use interp2
#for i = 1:nInt
#  if isempty (find (t_Qtrain(:,i) == 0)) && isempty (find (t_Qtrain(1,i:end) == 0))
#    temp = t_Qtrain(:,i:end);
#    break;
#  endif
#endfor
#t_Qtrain = temp;
#clear temp;

## Building the emulator
# extracting the parameters making the regular grid
sat_train = soil_saturations;
ri_train  = rain_intensities;
[ri_train sat_train] = meshgrid (ri_train, sat_train);

# create sampling for the emulator
sat_emu = linspace (0, 1, 100);
ri_emu  = linspace (min (min (ri_train)), max (max (ri_train)), 100);
[ri_emu sat_emu] = meshgrid (ri_emu, sat_emu);

# create grid for test and validation
[ri_test sat_test] = meshgrid (rain_intensities_test, soil_saturations_test);
[ri_val sat_val] = meshgrid (rain_intensities_val, soil_saturations_val);

## Generating the plot for the emulator
#
method = 'cubic';
#t_Qts_emu_na = interp2 (ri_train, sat_train, t_Qtrain_na, ri_emu, sat_emu, 'nearest');
t_Qts_emu_0 = interp2 (ri_train, sat_train, t_Qtrain_0, ri_emu, sat_emu, method);


figure (1)
htr = plot3 (ri_train, sat_train, t_Qtrain_0, 'ro', 'markerfacecolor', 'r');
hold on
hte = plot3 (ri_test, sat_test, t_Qtest, 'bo', 'markerfacecolor', 'b');
hva = plot3 (ri_val, sat_val, t_Qval, 'go', 'markerfacecolor', 'g');
he = mesh (ri_emu, sat_emu, t_Qts_emu_0, 'edgecolor', 'k', 'facecolor', 'none');
hold off
legend ([he, htr(1), hte(1), hva(1)], 'emulator', 'training', 'test', 'validation')
xlabel ('ri [mm/h]')
ylabel ('\Delta\theta [-]')
zlabel ('t(Q_{thrsh} [min])')
grid off;
view (136, 41)
print ('emulator.eps', '-color')
#ifelse(isfinite(t_Qts_emu_na), t_Qts_emu_0, t_Qts_emu_na)

## Performing test and validation
# test
[ri_test sat_test] = meshgrid (rain_intensities_test, soil_saturations_test);
tic
t_Qts_test = interp2 (ri_train, sat_train, t_Qtrain_0, ri_test, sat_test, method);
toc

# validation
[ri_val sat_val] = meshgrid (rain_intensities_val, soil_saturations_val);
tic
t_Qts_val = interp2 (ri_train, sat_train, t_Qtrain_0, ri_val, sat_val, method);
toc



## Extract training data for building the emulator
# method: griddata
#[j,k]    = find (t_Qtrain_0);

#ri_train_gd(:,1)  = rain_intensities(k(:));
#sat_train_gd(:,1) = soil_saturations(j(:));
#t_Qtrain     = nonzeros (t_Qtrain_0);

#t_Qts_emu = griddata (ri_train, sat_train, t_Qtrain_0, ri_emu, sat_emu, 'linear');

#figure (2)
#plot3 (ri_train, sat_train, t_Qtrain_0, 'ro', 'markerfacecolor', 'r');
#hold on
#mesh (ri_emu, sat_emu, t_Qts_emu, 'edgecolor', 'k');
#hold off






