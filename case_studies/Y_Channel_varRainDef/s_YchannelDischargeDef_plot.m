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
pkg load geometry

## Load and manipulate input data
#
load ('indexes_table.dat');
load ('qt_bbound.dat');
load ('qt_bchannel.dat');
load ('parameters.dat');
load ('soil_saturations.dat');
load ('rain_intensities.dat');

nExp = length (qt_bbound);
nInt = length (rain_intensities);
nSat = length (soil_saturations);

t_min = (1:saved_states) * dt / 60; #[min]
rain_intensities_h = rain_intensities * 1000 * 60^2; #[m/s -> mm/h]
[tt rri_t] = meshgrid (t_min, rain_intensities_h);
tt = tt.'; rri_t = rri_t.';

rain_duration = rain_duration / 60; #[s->min]

for n = 1:nExp
  q_temp(:,indexes_table(n,2),indexes_table(n,1)) = qt_bbound{n};
endfor
qt_bbound = q_temp;
clear q_temp;

save ('qt_bbound_mat.dat', 'qt_bbound');


## Produce the plots
# hydrographs plot

f=1;
figure (f)
f+=1;
colr = copper (nSat);

refline = zeros (size(tt));

miri = min (rain_intensities_h);
mari = max (rain_intensities_h);
mQmax = max (max( max(qt_bbound)));
polyg = [
         rain_duration miri 0;
         rain_duration mari 0;
         rain_duration mari mQmax;
         rain_duration miri mQmax;
        ];

drawPolygon3d (polyg, ':r', 'linewidth', 0.5);
hold on
plot3 (tt, rri_t, refline, 'linestyle', '--', 'linewidth', 0.5, 'color', 'k');
for s = 1:nSat
  leg{s} = sprintf ('\\Delta\\theta = %0.2f', soil_saturations(nSat+1-s));
  h3(s,:) = plot3 (tt, rri_t, qt_bbound(:,:,nSat+1-s), 'color', colr(nSat+1-s,:), 'linewidth', 1);
endfor
hold off
legend (h3(:), leg{:}, 'location', 'northwest');
grid ('off')
axis tight;
#title ('Hydrograph for the bottom boundary')
view (31, 49)
#view (72, 58)
set (gca, 'box', 'off')
xlabel ('t [min]');
ylabel ('ri [mm/h]');
zlabel ('Q [m^3/s]');
print ('hydrographs3d.eps', '-color')
print ('hydrographs3d.png', '-r300')



## Qmax plot
#figure (2)
#for n = 1:nExp
#  hold on
#  hp31 = plot3 (rain_intensities_h(indexes_table(n,2)), ...
#  soil_saturations(indexes_table(n,1)), Qmax(n), 'ro');
#  hold off
#  set (hp31, 'markerfacecolor', 'r');
#endfor
#view (-20, 33);
#grid ('on');
#title ('Q_{max} as a function of (r, \Delta\theta)')
#xlabel ('r [mm/h]');
#ylabel ('\Delta\theta [-]');
#zlabel ('Q_{max} [m^3/s]');
##print ('sampling_outputQmax.eps', '-color');

## t(Qmax) plot
#figure (3)
#for n = 1:nExp
#  hold on
#  hp32 = plot3 (rain_intensities_h(indexes_table(n,2)), ...
#  soil_saturations(indexes_table(n,1)), t_Qmax_h(n), 'bo');
#  hold off
#  set (hp32, 'markerfacecolor', 'b');
#endfor
#view (-50, 44);
#grid ('on');
#title ('t(Q_{max}) as a function of (r, \Delta\theta)')
#xlabel ('r [mm/h]');
#ylabel ('\Delta\theta [-]');
#zlabel ('t(Q_{max}) [h]');
##print ('sampling_outputTQmax.eps', '-color');

# topography plot
topo_plt = true;
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
  print ('topography.png', '-r300');
endif




