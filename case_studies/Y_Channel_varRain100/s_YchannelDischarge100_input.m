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
## Created: 2018-02-01

pkg load fswof2d

inputsFolder = 'Inputs';

if !exist (inputsFolder, 'dir')
  mkdir (inputsFolder);
endif

## Utility functions - Can be written to separated files in the future
fname = @(s) fullfile (inputsFolder, s);

function zz = gauss3d (A, xx, yy, x0, y0, sig_x, sig_y)
  zz = A * exp (- ((xx - x0).^2/(2*sig_x^2) + (yy - y0).^2/(2*sig_y^2)));
endfunction



## Script
# the domain is a 2km x 2km catchment
# TODO perform mesh study for grid convergence
# here Nx = Ny = 100, dx = dy = 20m

Lx = 2000;
Ly = 2000;
Nx = 100;
Ny = 100;


x = linspace (0, Lx, Nx+1);
y = linspace (0, Ly, Ny+1);

x = node2center (x);
y = node2center (y);

[XX YY] = meshgrid (x, y);


## Generate the gaussian bumps (mountains)
ZZg1 = gauss3d (700, XX, YY, 700, 1700, 300, 200);
ZZg2 = gauss3d (500, XX, YY, 300, 500, 200, 300);
ZZg3 = gauss3d (300, XX, YY, 1700, 500, 400, 500);


## Generate a sloping plane
nf = @(d1,d2) [cosd(d2).*sind(d1) sind(d2).*sind(d1) cosd(d1)];
alpha = 8; # slope in deg
np = nf (alpha, 0);
ZZpl = (np(1) * YY + np(2) * XX ) ./ np(3);

## Generate a parabole
a = 1e-4;
b = -Lx/2*2*a;
c = 100;
Zpb = a*x.^2 + b*x + c;

ZZpb = repmat (Zpb, Ny, 1);

## Resulting topography: sum of the different features
ZZ = ZZpl + ZZpb + ZZg1 + ZZg2 + ZZg3;


## Produce the plot
# import the gist_earth colorbar
if ~exist ('gist_earth.m')
  matplotlib_cm ('gist_earth');
endif
cc = gist_earth (64);
colormap (cc)

h = struct ();
h.surf = surf (XX, YY, ZZ);
shading interp
axis equal
l = light ('position', [1 0.5 1]);
hold on
contour3 (XX, YY, ZZ, 25, 'linecolor', 'k', 'linewidth', 0.4);
hold off

## Convert data to fswof2d format and save them as topography file
# convert data
[X Y Z] = dataconvert ('fswof2d', XX, YY, ZZ);

# save data
topofile = 'topography.dat';
topo2file (X, Y, Z, fname (topofile));

## Generate the different parameters sampling
# duration sampling
rain_durations = [60 120 180]; #[min]
rain_durations = rain_durations * 60; #[s]
save ('rain_durations.dat', 'rain_durations');

sim_durations = [3 5 7]; #[h]
sim_durations = sim_durations * 60^2; #[s]
save ('sim_durations.dat', 'sim_durations');

# intensity sampling
rain_intensities = [10 15 25]; #[mm/h]
rain_intensities = rain_intensities / (1000 * 60^2);
save ('rain_intensities.dat', 'rain_intensities');

# saturation sampling
soil_saturations = [0.25 0.75];
save ('soil_saturations.dat', 'soil_saturations');

## Generate rain and parameters files
nrd  = length (rain_durations);
nri  = length (rain_intensities);
nsat = length (soil_saturations);

for i = 1:nri
  for d = 1:nrd
    rain = [0 rain_intensities(i); rain_durations(d) 0];
    rainfile = sprintf ('rain_%02d%02d.dat', i, d);
    save (fname (rainfile), 'rain');
    for s = 1:nsat
      suffix = sprintf ('_%01d_%02d%02d', s, i, d);
      params = params2file ('xCells', Nx, ...
                            'yCells', Ny, ...
                            'SimDuration', sim_durations(d), ...
                            'SavedStates', sim_durations(d) /30, ...
                            'xLength', Lx, ...
                            'yLength', Ly, ...
                            'BotBoundCond', 3, ...
                            'InfiltrationModel', 1, ...
                            'TopographyFile', topofile, ...
                            'huvInit', 2, ...
                            'RainInit', 1, ...
                            'HydrCondCrustCoef', 5e-6, ...
                            'HydrCondSoilCoef', 2e-7, ...
                            'WaterContentVal', soil_saturations(s), ...
                            'WetFrontSuccHeadVal', 0.09, ...
                            'MaxInfiltrationRateVal', 5.5e-6, ...
                            'RainFile', rainfile, ...
                            'OutputsSuffix', suffix, ...
                            'ParametersFile', fname (strcat ('parameters', suffix, '.txt'))
                          );

      if !exist (strcat ('Outputs', suffix))
        mkdir (strcat ('Outputs', suffix));
      endif
    endfor
  endfor
endfor


## Write bash script to run study
bfile = "run.sh";
printf ("Writing Bash script to file %s\n", bfile); fflush (stdout);
timetxt = strftime ("%Y-%m-%d %H:%M:%S", localtime (time ()));
bsh = {
'#!/bin/bash', ...
sprintf("## Automatically generated on %s\n", timetxt), ...
'nohup parallel -j+0 --eta fswof2d -f {} ::: $(basename -a Inputs/parameters*)'
};
bsh = strjoin (bsh, "\n");
fid = fopen (bfile, "wt");
fputs (fid, bsh);
fclose (fid);




