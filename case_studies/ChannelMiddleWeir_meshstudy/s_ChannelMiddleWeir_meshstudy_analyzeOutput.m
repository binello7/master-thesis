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
clear all
## Load the variables
# load variables if not present in workspace
if !exist ('H', 'var')
  fextractdata = 'extracted_data.dat';
  load (fextractdata);
endif

Y_max(2:end) = Y_max(2:end) + 0.5 * dy(2:end);
perc_diff_middleweir_h = abs (diff (middleweir_head)) ...
                         ./ middleweir_head(2:end) * 100;
perc_diff_H_max = abs (diff (H_max)) ./ H_max(2:end) * 100;
perc_diff_Y_max = abs (diff (Y_max)) ./ Y_max(2:end) * 100;



## Generate the plots of the analyzed variables
# generate the legend
for i = 1:nExp
  leg{i} = sprintf ('Nx = %d, Ny = %d', Nx(i), Ny(i));
endfor

# plot 1: water head over the middle of the weir
figure (1)
plot (dy, middleweir_head, '-o');
#title ('Convergence at center of weir')
xlabel ('dy [m]');
ylabel ('height over weir [m]')
print ('convergence_center.png', '-r300');

# plot 2: % variation over the middle of the weir
figure (2)
semilogy (dy(2:end), perc_diff_middleweir_h, 'r-o');
#title ('% variation at center of weir')
xlabel ('dy [m]');
ylabel ('h variation [%]')
print ('diff_center.png', '-r300');

# plot 3: maximum water head
figure (3)
plot (dy, H_max, '-o');
#title ('Convergence max water depth')
xlabel ('dy [m]');
ylabel ('h_{max} [m]')
print ('convergence_hmax.png', '-r300');

# plot 4: % variation maximum water head
figure (4)
semilogy (dy(2:end), perc_diff_H_max, 'r-o');
#title ('% variation max water depth')
xlabel ('dy [m]');
ylabel ('h_{max} variation [%]')
print ('diff_hmax.png', '-r300');

# plot 5: distance at which max water head occurs
figure (5)
plot (dy, Y_max, '-o');
#title ('Convergence max water depth location')
xlabel ('dy [m]');
ylabel ('h_{max} location [m]')
print ('convergence_ymax.png', '-r300');

# plot 7: profile along che middle of the channel
figure (7)
plot (Y{1}, Z{1}, 'k', 'linewidth', 2);
Yp{1} = Y{1};
for i = 1:nExp
  if i > 1
    Yp{i} = Y{i} + 0.5 * dy(i);
  endif
  hold on;
  plot (Yp{i}, HZ{i}((length (HZ{i}):-1:1)));
  hold off;
endfor
#title ('Free surface profiles')
legend ('channel profile', leg{:}, 'location', 'northeast');
annotation ('textarrow', [0.3 0.35], [0.7 0.7], 'string', ' flow direction', ...
            'color', 'b', 'headlength', 6, 'headwidth', 6)
xlabel ('Ly [m]');
ylabel ('h [m]')
print ('water_profiles.png', '-r300')

