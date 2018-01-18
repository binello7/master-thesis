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

close all

if !exist ('HH', 'var')
  dataFolder  = 'data';
  studyName   = 'ChannelMiddleWeir_meshstudy_2';
  studyFolder   = fullfile (dataFolder, studyName);

  fextractdata = fullfile (studyFolder, 'extracted_data.dat');
  finputvar    = fullfile (studyFolder, 'input_variables.dat');
  
  load (fextractdata);
  load (finputvar);
endif

tmax = size (HH{1})(3);
weir_mes_pos = (wTop_l + wTop_r) / 2;

middleweir_head         = zeros (1, nExp);


for i = 1:nExp
  Y{i} = YY{i}(:,1);
  Z{i} = ZZ{i}(:,1);
  H{i} = mean (HH{i}(:, round (end/2), 100:end), 3);
  [H_max(i), max_idx(i)] = max (H{i});
  HZ{i} = H{i} + Z{i};
  middleweir_head(i) = interp1 (Y{i}, H{i}, weir_mes_pos);
  dy(i) = Ly / Ny(i);
  leg{i} = sprintf ('dx = dy = %d', dy(i));
endfor

Y_max = (max_idx - 1) .* dy .+ 0.5 * dy;


r = dy(1:end-1) ./ dy(2:end);
rc = r(1);
epsilon = middleweir_head(1:end-1) - middleweir_head(2:end);
p = log (epsilon(1:end-1) / epsilon(2:end)) ./ log (r(1:end-1));
pc = p(1);
Fs = 1.25;
GCI = Fs * abs (epsilon) ./ (middleweir_head(2:end) *
      (rc^pc - 1));
GCI = GCI * 100;

## Generate the plots of the analyzed variables
# plot 1: water head over the middle of the weir
figure (1)
plot (dy, middleweir_head, '-o');
title ('Convergence study at center of weir')
xlabel ('dx [m]');
ylabel ('height over weir [m]')

# plot 2: maximum water head
figure (2)
plot (dy, H_max, '-o');
title ('Convergence study for max water depth')
xlabel ('dx [m]');
ylabel ('h_{max} [m]')

# plot 3: distance at which max water head occurs
figure (3)
plot (dy, Y_max, '-o');
title ('Convergence study for max water depth location')
xlabel ('dx [m]');
ylabel ('location of h_{max} [m]')

figure (4)
plot (Y{nExp}, Z{nExp}, 'k', 'linewidth', 2);
for i = 1:nExp
  hold on;
  plot (Y{i}, HZ{i});
  hold off;
endfor
title ('Free surface profiles')
legend ('channel profile', leg{:}, 'location', 'northwest');
annotation ('textarrow', [0.7 0.65], [0.8 0.8], 'string', ' flow direction', ...
            'color', 'b', 'headlength', 6, 'headwidth', 6)
xlabel ('Ly [m]');
ylabel ('h [m]')


#ymax = ceil (max (max (max (HH{1}))));
#ymin = ceil (min (min (min (HH{1}))));
#gh = zeros (nExp, 1);

#figure (1)
##i = 3;
#for i = 1:nExp
#  hold on
#  gh(i,1) = plot (YY{i}(:,1), HH{i}(:,round (end/2),1));
##  surf (XX{i}, YY{i}, ZZ{i}, 'facecolor', 'k');
##  hold on
##  gh(i,1) = mesh (XX{i}, YY{i}, HHz{i}(:,:,1), 'facecolor', 'none', 'edgecolor', 'b');
#  hold off
#  leg{i,1} = sprintf ('Ny = %d', Ny(i));
#endfor
#legend (leg);
#tx = text (35, 3, sprintf ("t = %d s", 1));
#axis ([0 Ly ymin ymax]);
##axis equal

#for t = 1:tmax
#  for i = 1:nExp
#    set (gh(i,1), 'ydata', HH{i}(:,round (end/2),t));
##    set (gh(i,1), 'zdata', HHz{i}(:,:,t));
#  endfor
#  set (tx, 'string', sprintf ("t = %d s", t))
#  pause (0.5)
#endfor



