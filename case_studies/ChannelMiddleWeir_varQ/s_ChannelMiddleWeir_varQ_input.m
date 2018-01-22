## Copyright (C) 2018 Sebastiano Rusca
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##g
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.
##
## Author: Sebastiano Rusca <sebastiano.rusca@gmail.com>
## Created: 2018-01-08

pkg load fswof2d
pkg load linear-algebra
close all



## Generate needed folders for FullSWOF_2D
inputsFolder  = 'Inputs';
outputsFolder = 'Outputs';
fname         = @(s) fullfile (inputsFolder, s);
suffname      = @(s,d) sprintf ('%s_%02d.txt', s, d);
if !exist (inputsFolder, 'dir')
  mkdir (inputsFolder);
endif

## Study variable
# These are the variables that we will change in this study
nQ        = 25;
Qin       = linspace (-0.1, -10, nQ);

# Order to explore extremes
tmp = zeros (1,nQ);
tmp(1:2:end) = Qin(1:ceil(end/2));
tmp(2:2:end) = fliplr (Qin)(1:ceil(end/2)-1);
Qin = tmp;
clear tmp

## Parameters that don't change in the loop
B = 4;
Ly = 40;     # length of the channel, same for all experiments
Nx = 40;
Ny = 400;
dy = Ly / Ny; 

# define the longitudinal profile of the weir and that of the free surface
weir_height = 3;

wBot_r = 17 - 0.5 * dy;
wTop_r = 19 - 0.5 * dy;
wTop_l = 21 - 0.5 * dy;
wBot_l = 23 - 0.5 * dy;

pweir  = interp1 ([0 wBot_r wTop_r wTop_l wBot_l Ly], [0 0 weir_height weir_height 0 0], 'pp');
hwater = interp1 ([0 wTop_l wBot_l Ly], [0 0 weir_height weir_height], 'pp');

# generate nodes vectors
x = linspace (0, B, Nx+1);
xc = node2center (x);
y = linspace (0, Ly, Ny+1);
yc = node2center (y);

# generate nodes meshes
[XX YY] = meshgrid (xc, yc);

# generate the weir topography
zc = (ppval (pweir, yc)).';
ZZ = repmat (zc, 1, Nx);


## Generate initial conditions for h, depending on weir position
hc = (ppval (hwater, yc)).';
HH = repmat (hc, 1, Nx);

# generate the free surface
HZ = ZZ + HH;

# u and v can be set to 0
UU = zeros (Ny, Nx);
VV = zeros (Ny, Nx);

surf (XX, YY, ZZ);
hold on
mesh (XX, YY, HZ, 'facecolor', 'none', 'edgecolor', 'b');
hold off
axis ([0 B 0 Ly 0 weir_height]);
text (3.5, 5, 4.3, sprintf ('Nx = %d', Nx))
text (3.5, 5, 4, sprintf ('Ny = %d', Ny))
print ('exp_varQ_set-up.png', '-r300');

#  Convert the data to the FullSWOF_2D format
[X Y Z H U V] = dataconvert ('fswof2d', XX, YY, ZZ, HH, UU, VV);

#  Write the topography to the file
topofile = "topography.dat";
topo2file (X, Y, Z, fname (topofile));

#  Write the initial conditions to the file
huvfile = "huv_init.dat";
huv2file (X, Y, H, U, V, fname (huvfile));

for i = 1:nQ
  ## Generate the parameters varying from one experiment to the other

  #  Write the simulation parameters to a file
  sim_duration    = 200;
  saved_states    = 200;
  top_boundary    = 5;
  top_Q           = Qin(i);
  top_h           = weir_height;
  bot_boundary    = 3;
  out_suff        = sprintf ('_%02d', i);
  paramsfile      = suffname ("parameters", i);
  p = params2file ('xCells', Nx, 'yCells', Ny, 'xLength', B, ...
              'yLength', Ly, 'SimDuration', sim_duration, ...
              'SavedStates', saved_states, 'BotBoundCond', bot_boundary, ...
              'TopBoundCond', top_boundary, 'TopImposedQ', top_Q, ...
              'TopimposedH', top_h, ...
              'huvFile', huvfile, ...
              'TopographyFile', topofile, ...
              'ParametersFile', fname (paramsfile), ...
              'OutputsSuffix', out_suff);

  # generate the 'Outputs' folders
  suffoutputsFolder = strcat (outputsFolder, out_suff);
  if !exist (suffoutputsFolder, 'dir')
    mkdir (suffoutputsFolder);
  endif

endfor

close all

## Write bash script to run study
bfile = "run.sh";
printf ("Writing Bash script to file %s\n", bfile); fflush (stdout);
timetxt = strftime ("%Y-%m-%d %H:%M:%S", localtime (time ()));
bsh = {
'#!/bin/bash', ...
sprintf("## Automatically generated on %s\n", timetxt), ...
'echo Started on $(date)', ...
sprintf("for i in {1..%d}; do", nQ), ...
sprintf("  id=`printf %%02d $i`"), ...
'  nohup time fswof2d -f parameters_$id.txt &', ...
'  if(( ($i % $(nproc)) == 0)); then wait; fi', ...
'done', ...
};
bsh = strjoin (bsh, "\n");
fid = fopen (bfile, "wt");
fputs (fid, bsh);
fclose (fid);

# save global variables
save ('input_variables.dat', 'weir_height', 'pweir', 'dy');
save ('input_Q.dat', 'Qin');
clear all


