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

## Extract the idx of Q exceeding Q threshold


load ('qt_bbound_mat.dat');
load ('qt_bbound_test.dat');
load ('qt_bbound_val.dat');
load ('qt_bbound_svm.dat');
load ('soil_saturations.dat');
load ('soil_saturations_test.dat');
load ('soil_saturations_val.dat');
load ('soil_saturations_svm.dat');
load ('rain_intensities.dat');
load ('rain_intensities_test.dat');
load ('rain_intensities_val.dat');
load ('rain_intensities_svm.dat');
load ('parameters.dat');

Q_trhsh = 0.17; #[m3/s];
#Q_trhsh = 0.3; #[m3/s];
#Q_trhsh = 0.8; #[m3/s];


nri = length (rain_intensities);
nss = length (soil_saturations);

# training data
idx_train = zeros (nss, nri);
for i = 1:nri
  for s = 1:nss
    if isempty (find (qt_bbound(:,i,s) >= Q_trhsh, 1))
      idx_train(s,i) = 7*60;
    else
      idx_train(s,i) = find (qt_bbound(:,i,s) >= Q_trhsh, 1);
      #threshold was exceeded between this index and the previous one -> average
      idx_train(s,i) = idx_train(s,i) - 0.5;
    endif
  endfor
endfor


# test data
j = 1;
idx_test = zeros (length (rain_intensities_test), length (soil_saturations_test));
for i = 1:length(rain_intensities_test)
  for s = 1:length(soil_saturations_test)
    if isempty (find (qt_bbound_test(j,:) >= Q_trhsh, 1))
      idx_test(i,s) = 7*60;
    else
      idx_test(i,s) = find (qt_bbound_test(j,:) >= Q_trhsh, 1);
      #threshold was exceeded between this index and the previous one -> average
      idx_test(i,s) = idx_test(i,s) - 0.5;
    endif
    j+=1;
  endfor
endfor


# validation data
idx_val = zeros (length (rain_intensities_val),1);
for i = 1:length(rain_intensities_val)
  if isempty (find (qt_bbound_val(i,:) >= Q_trhsh, 1))
    idx_val(i,1) = 7*60;
  else
    idx_val(i,1) = find (qt_bbound_val(i,:) >= Q_trhsh, 1);
     #threshold was exceeded between this index and the previous one -> average
    idx_val(i,1) = idx_val(i,1) - 0.5;
  endif
endfor


# svm classifier
idx_class = zeros (length (rain_intensities_svm), 1);
for i = 1:length(rain_intensities_svm)
  if isempty (find (qt_bbound_svm(i,:) >= Q_trhsh, 1))
    idx_class(i,1) = 7*60;
  else
    idx_class(i,1) = find (qt_bbound_svm(i,:) >= Q_trhsh, 1);
    #threshold was exceeded between this index and the previous one -> average
    idx_class(i,1) = idx_class(i,1) - 0.5;
  endif
endfor

# converting the indexes in time
t_Qtrain  = idx_train * dt / 60; #[min]
t_Qtest  = idx_test * dt / 60; #[min]
t_Qval   = idx_val * dt / 60; #[min]
t_Qclass    = idx_class * dt / 60; #[min]


save ('t2thold_train.dat', 't_Qtrain')
save ('t2thold_test.dat', 't_Qtest')
save ('t2thold_val.dat', 't_Qval')
save ('t2thold_class.dat', 't_Qclass')

clear all

