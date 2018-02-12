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
## Created: 2018-02-05

clear all
close all
pkg load dataframe
pkg load fswof2d

## Load and manipulate input data
#
load ('indexes_table.dat');
load ('qt_bbound.dat');
load ('qt_bchannel.dat');
load ('parameters.dat');
load ('soil_saturations.dat');
load ('rain_intensities.dat');


rain_intensities_h = rain_intensities * 1000 * 60^2; #[m/s -> mm/h]
nExp = length (qt_bbound);
#nExp = 6;

## Extract Qmax for every curve
#
[Qmax idx_max] = cellfun (@max, qt_bbound);
t_Qmax = idx_max * dt; #[s]
t_Qmax_h = t_Qmax / 3600;




## Produce the plots
# hydrographs plot
figure (1)
colr = jet (nExp);
t = (1:saved_states) * dt;
for n = 1:nExp
  leg{n} = sprintf ('Exp #%02d', n);
  hold on
  hp = plot (t, qt_bbound{n});
  set(hp,'color',colr(n,:))
  hold off
endfor
hl = legend (gca, leg{:});
set (hl, 'fontsize', 7, 'box', 'off')
title ('Hydrograph for the bottom boundary (low K_s)')
xlabel (gca, 't [s]');
ylabel (gca, 'Q [m^3/s]')
print ('hydrographs_lks.png');


# Qmax plot
figure (2)
for n = 1:nExp
  hold on
  hp31 = plot3 (rain_intensities_h(indexes_table(n,2)), ...
  soil_saturations(indexes_table(n,1)), Qmax(n), 'ro');
  hold off
  set (hp31, 'markerfacecolor', 'r');
endfor
view (-20, 33);
grid ('on');
title ('Q_{max} as a function of (r, \Delta\theta), low K_s')
xlabel ('r [mm/h]');
ylabel ('\Delta\theta [-]');
zlabel ('Q_{max} [m^3/s]');
print ('sampling_outputQmax.png');

# t(Qmax) plot
figure (3)
for n = 1:nExp
  hold on
  hp32 = plot3 (rain_intensities_h(indexes_table(n,2)), ...
  soil_saturations(indexes_table(n,1)), t_Qmax_h(n), 'bo');
  hold off
  set (hp32, 'markerfacecolor', 'b');
endfor
view (-50, 44);
grid ('on');
title ('t(Q_{max}) as a function of (r, \Delta\theta), low K_s')
xlabel ('r [mm/h]');
ylabel ('\Delta\theta [-]');
zlabel ('t(Q_{max}) [h]');
print ('sampling_outputTQmax.png');

# topography plot
topo_plt = false;
if topo_plt
  load ('Inputs/topography.dat');
  X = topography(:,1); Y = topography(:,2); Z = topography(:,3);
  [X Y Z] = dataconvert ('octave', [Nx Ny], X, Y, Z);
  cc = gist_earth (64);

  h = struct ();
  figure
  colormap (cc);
  h.surf = surf (X, Y, Z, 'edgecolor', 'none');
  shading interp
  hold on
  h.cont = contour3 (X, Y, Z, 20, 'linecolor', 'k', 'linewidth', 0.4);
  #h.light = light ();
  hold off
  xlabel ('X [m]');
  ylabel ('Y [m]');
  zlabel ('Z [m]');
  print ('topography.png', '-color');
endif




