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
pkg load fswof2d

inputsFolder = 'Inputs';

load ('parameters.dat');
fname = @(s) fullfile (inputsFolder, s);


## Generate the different parameters for validation

# intensity sampling
rain_intensities_val = [15 20 22 25 25 35].';
save ('rain_intensities_val.dat', 'rain_intensities_val');
rain_intensities_val  = rain_intensities_val / (1000 * 60^2);

# saturation sampling
soil_saturations_val  = [0.1 0.8 0.5 0.2 0.6 0.2].';
save ('soil_saturations_val.dat', 'soil_saturations_val');


## Generate validation parameters files
nv  = length (rain_intensities_val);

for i = 1:nv
  rain = [0 rain_intensities_val(i); rain_duration 0];
  rainfile = sprintf ('rain_v%02d.dat', i);
  save (fname (rainfile), 'rain');
  suffix = sprintf ('_v%02d', i);

  params = params2file ('xCells', Nx, ...
                        'yCells', Ny, ...
                        'SimDuration', sim_duration, ...
                        'SavedStates', saved_states, ...
                        'xLength', Lx, ...
                        'yLength', Ly, ...
                        'BotBoundCond', 3, ...
                        'InfiltrationModel', 1, ...
                        'TopographyFile', 'topography.dat', ...
                        'huvInit', 2, ...
                        'RainInit', 1, ...
                        'HydrCondCrustCoef', Ks, ...
                        'HydrCondSoilCoef', Ks, ...
                        'DeltaWaterContentVal', soil_saturations_val(i), ...
                        'WetFrontSuccHeadVal', psi_f, ...
                        'MaxInfiltrationRateVal', 5.5e-6, ...
                        'RainFile', rainfile, ...
                        'OutputsSuffix', suffix, ...
                        'ParametersFile', fname (strcat ('parameters', suffix, '.txt'))
                        );

  if !exist (strcat ('Outputs', suffix))
    mkdir (strcat ('Outputs', suffix));
  endif
endfor


## Write bash script to run study
bfile = "runV.sh";
printf ("Writing Bash script to file %s\n", bfile); fflush (stdout);
timetxt = strftime ("%Y-%m-%d %H:%M:%S", localtime (time ()));
bsh = {
'#!/bin/bash', ...
sprintf("## Automatically generated on %s\n", timetxt), ...
'nohup parallel -j+0 --eta fswof2d -f {} ::: $(basename -a Inputs/parameters_v*) &'
};
bsh = strjoin (bsh, "\n");
fid = fopen (bfile, "wt");
fputs (fid, bsh);
fclose (fid);



