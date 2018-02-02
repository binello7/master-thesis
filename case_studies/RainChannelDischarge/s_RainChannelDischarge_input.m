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
## Created: 2018-01-31

pkg load fswof2d

inputsFolder = 'Inputs';
fname = @(s) fullfile (inputsFolder, s);

if !exist (inputsFolder, 'dir')
  mkdir (inputsFolder);
endif


Lx = 18;
Ly = 100;
Nx = 90;
Ny = 500;

[x z P xi zi] = csec_channel2lvlsym (Nx, 'Embankment', 3, 'Plain', 4, ...
                                     'RiverBank', 1, 'RiverBed', 2, ...
                                     'BankHeight', 2, 'EmbankmentHeight', 3);

y = linspace (0, Ly, Ny+1);

x = node2center (x);
y = node2center (y);
z = node2center (z);

[XX YY ZZc] = extrude_csec (x, y, z);

nf = @(d1,d2) [cosd(d2).*sind(d1) sind(d2).*sind(d1) cosd(d1)];
alpha = 10; # slope in deg
np = nf (alpha, 0);
ZZp = (np(1) * YY + np(2) * XX ) ./ np(3);
ZZ = ZZp + ZZc;

HH = zeros (size (XX));
UU = zeros (size (XX));
VV = zeros (size (XX));

[X Y Z H U V] = dataconvert ('fswof2d', XX, YY, ZZ, HH, UU, VV);


topofile = 'topography.dat';
topo2file (X, Y, Z, fname (topofile));


huvfile = 'huv_init.dat';
huv2file (X, Y, H, U, V, fname (huvfile));


tot_rain = 84; # mm/h
tot_rain = tot_rain / (1e3 * 60^2); # m/s

tot_time = 1; #h
tot_time = tot_time * 60^2;

# rain data matrix constant rain
rain_1 = [0 tot_rain/tot_time];

# rain data matrix triangular rain
i_max_tri = 2 * tot_rain / tot_time;
t_tri = transpose (linspace (0, 60*60, 13));
pp_tri = interp1 ([0 tot_time/2 tot_time], [0 i_max_tri 0], 'pp');
rain_2 = [t_tri ppval(pp_tri, t_tri)];

# rain data matrix trapezoidal rain
i_max_tra = 2 * tot_rain / (tot_time + 0.5*tot_time);
t_tra = t_tri;
pp_tra = interp1 ([0 tot_time/4 3*tot_time/4 tot_time], [0 i_max_tra i_max_tra 0], 'pp');
rain_3 = [t_tra ppval(pp_tra, t_tra)];

save (fname ('rain_01.dat'), 'rain_1');
save (fname ('rain_02.dat'), 'rain_2');
save (fname ('rain_03.dat'), 'rain_3');

params = params2file ('xCells', Nx, ...
                      'yCells', Ny, ...
                      'SimDuration', tot_time, ...
                      'SavedStates', tot_time /10, ...
                      'xLength', Lx, ...
                      'yLength', Ly, ...
                      'BotBoundCond', 3, ...
                      'TopBoundCond', 3, ...
                      'InfiltrationModel', 1, ...
                      'TopographyFile', topofile, ...
                      'huvFile', huvfile, ...
                      'RainInit', 1
                      );

for i = 1:3
  rainfile   = sprintf ('rain_%02d.dat', i);
  outputsuff = sprintf ('_%02d', i);
  paramsfile = sprintf ('parameters_%02d.txt', i);

  params = params2file (params, 'RainFile', rainfile, ...
                        'OutputsSuffix', outputsuff, ...
                        'ParametersFile', fname (paramsfile));

suffOutput = @(n) sprintf ('Outputs_%02d', n);

  if !exist (suffOutput (i), 'dir')
    mkdir (suffOutput (i));
  endif

endfor


