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

miri = min (rain_intensities_h);
mari = max (rain_intensities_h);
mQmax = max (max( max(qt_bbound)));


## Produce the plots
# plot: all hydrographs
f=1;
figure (f)
f+=1;
colr = copper (nSat);

refline = zeros (size(tt));

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
  leg{s} = sprintf ('\\theta_i = %0.2f', 1-soil_saturations(nSat+1-s));
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
ylabel ('I [mm/h]');
zlabel ('Q [m^3/s]');
print ('hydrographs3d.png', '-r300')


# plot: single hydrograph
figure (f)
f+=1;

ri = 9;
ss = 3;
Q1 = 0.7;
t1 = interp1 (qt_bbound(:,ri,ss), t_min, Q1);
Q2 = 0.8;
t2 = interp1 (qt_bbound(:,ri,ss), t_min, Q2);
tmax = max (t_min);

plot (t_min, qt_bbound(:,ri,ss), 'b', 'linewidth', 1);
hold on
line ([rain_duration rain_duration], [0, max(qt_bbound(:,ri,ss))], 'color', 'k', ...
      'linestyle', '-');
ha = annotation ("textarrow", 1/tmax*[rain_duration-50 rain_duration-11], ...
            [0.3 0.3], 'headstyle', 'vback1', 'headwidth', 5, 'headlength', 5, ...
            'string', 'rain duration ', 'fontsize', 9);
line ([t1 t1], [0 Q1], 'linestyle', '--');
text (t1+3, 0.033, 't_!', 'fontweight', 'bold');
line ([0 tmax], [Q1 Q1]);
text (5, Q1+0.033, 'Q_!', 'fontweight', 'bold');
line ([0 tmax], [Q2 Q2]);
text (5, Q2+0.033, 'Q\prime_!', 'fontweight', 'bold');
line ([t2 t2], [0 Q2], 'linestyle', '--');
text (t2+3, 0.033, 't\prime_!', 'fontweight', 'bold');



hold off
legend (sprintf ('\\Delta\\theta = %0.2f, I = %0.1f mm/h', soil_saturations(ss), rain_intensities_h(ri)),'location', 'northwest');
axis tight
xlabel ('t [min]');
ylabel ('Q [m^3/s]');
print ('hydrograph.png', '-r300');




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


