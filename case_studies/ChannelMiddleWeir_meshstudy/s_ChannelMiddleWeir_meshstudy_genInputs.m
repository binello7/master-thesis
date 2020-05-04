%% Copyright (C) 2018 Sebastiano Rusca
%%
%% This program is free software; you can redistribute it and/or modify it
%% under the terms of the GNU General Public License as published by
%% the Free Software Foundation; either version 3 of the License, or
%% (at your option) any later version.
%%
%% This program is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public License
%% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%%
%% Author: Sebastiano Rusca <sebastiano.rusca@gmail.com>
%% Created: 2018-01-08

pkg load fswof2d
pkg load linear-algebra

%% Generate needed folders for FullSWOF_2D
dataFolder    = 'data';
imagesFolder  = 'img';
inputsFolder  = fullfile (dataFolder, 'Inputs');
outputsFolder = fullfile (dataFolder, 'Outputs');
fname         = @(s) fullfile (inputsFolder, s);
suffname      = @(s,d) sprintf ('%s_%02d.dat', s, d);

if !exist (inputsFolder, 'dir')
  mkdir (inputsFolder);
endif

if !exist (imagesFolder, 'dir')
  mkdir (imagesFolder);
endif

%% Parameters that don't change in the loop
B = 4;
Ly = 40;     % length of the channel, same for all experiments
Nx = [2 4 8 20 40 80 100];
Ny = [20 40 80 200 400 800 1000];
dy = Ly ./ Ny;
nExp = length (Nx);     % how many experiments we run

%% Define the longitudinal profile of the weir and that of the free surface
weir_height = 3;

wBot_r(1) = 17;
wTop_r(1) = 19;
wTop_l(1) = 21;
wBot_l(1) = 23;

wBot_r(2:nExp) = wBot_r(1) - 0.5 * dy(2:nExp);
wTop_r(2:nExp) = wTop_r(1) - 0.5 * dy(2:nExp);
wTop_l(2:nExp) = wTop_l(1) - 0.5 * dy(2:nExp);
wBot_l(2:nExp) = wBot_l(1) - 0.5 * dy(2:nExp);


for i = 1:nExp
  %% Generate the parameters varying from one experiment to the other
  % generate the profile of the weir
  pweir  = interp1 ([0 wBot_r(i) wTop_r(i) wTop_l(i) wBot_l(i) Ly], [0 0 weir_height weir_height 0 0], 'pp');
  hwater = interp1 ([0 wTop_l(i) wBot_l(i) Ly], [0 0 weir_height weir_height], 'pp');

  % generate nodes vectors
  x = linspace (0, B, Nx(i)+1);
  xc = node2center (x);
  y = linspace (0, Ly, Ny(i)+1);
  yc = node2center (y);

  % generate nodes meshes
  [XX YY] = meshgrid (xc, yc);

  % generate the weir topography
  zc = (ppval (pweir, yc)).';
  ZZ = repmat (zc, 1, Nx(i));


  %% Generate initial conditions for h, depending on weir position
  hc = (ppval (hwater, yc)).';
  HH = repmat (hc, 1, Nx(i));

  % generate the free surface
  HZ = ZZ + HH;

  % u and v can be set to 0
  UU = zeros (Ny(i), Nx(i));
  VV = zeros (Ny(i), Nx(i));

  figure ('visible', 'off')
  surf (XX, YY, ZZ);
  hold on
  mesh (XX, YY, HZ, 'facecolor', 'none', 'edgecolor', 'b');
  hold off
  axis ([0 B 0 Ly 0 weir_height]);
  text (3.5, 5, 4.3, sprintf ('Nx = %d', Nx(i)))
  text (3.5, 5, 4, sprintf ('Ny = %d', Ny(i)))
  print (gcf, fullfile (imagesFolder, ...
    sprintf ('experiment%02d_set-up.png', i)), '-r300');
  close all

  % Convert the data to the FullSWOF_2D format
  [X Y Z H U V] = dataconvert ('fswof2d', XX, YY, ZZ, HH, UU, VV);

  % Write the topography to the file
  topofile = suffname ("topography", i);
  topo2file (X, Y, Z, fname (topofile));

  % Write the initial conditions to the file
  huvfile = suffname ("huv_init", i);
  huv2file (X, Y, H, U, V, fname (huvfile));


  %  Write the simulation parameters to a file
  sim_duration    = 200;
  saved_states    = 200;
  top_boundary    = 5;
  top_Q           = -10;
  top_h           = weir_height;
  bot_boundary    = 3;
  out_suff        = sprintf ('_%02d', i);
  paramsfile      = suffname ("parameters", i);
  p = params2file ('xCells', Nx(i), 'yCells', Ny(i), 'xLength', B, ...
              'yLength', Ly, 'SimDuration', sim_duration, ...
              'SavedStates', saved_states, 'BotBoundCond', bot_boundary, ...
              'TopBoundCond', top_boundary, 'TopImposedQ', top_Q, ...
              'TopimposedH', top_h, 'huvFile', huvfile, ...
              'TopographyFile', topofile, 'ParametersFile', fname (paramsfile), ...
              'OutputsSuffix', out_suff);

  % generate the 'Outputs' folders
  suffoutputsFolder = strcat (outputsFolder, out_suff);
  if !exist (suffoutputsFolder, 'dir')
    mkdir (suffoutputsFolder);
  end%if

end%for


%% Write bash script to run study
bfile = "run.sh";
printf ("Writing Bash script to file %s\n", bfile); fflush (stdout);
timetxt = strftime ("%Y-%m-%d %H:%M:%S", localtime (time ()));
bsh = {
'#!/bin/bash', ...
sprintf("## Automatically generated on %s\n", timetxt), ...
'echo Started on $(date)', ...
'cd data', ...
sprintf("for i in {1..%d}; do", nExp), ...
sprintf("  id=`printf %%02d $i`"), ...
'  time nohup fswof2d-1.07 -f parameters_$id.dat', ...
'  if(( ($i % $(nproc)) == 0)); then wait; fi', ...
'done', ...
'echo Finished on $(date)'
};
bsh = strjoin (bsh, "\n");
fid = fopen (bfile, "wt");
fputs (fid, bsh);
fclose (fid);

% make file executable
system ('chmod +x run.sh');

% save global variables
save('input_variables.dat', 'weir_height', 'wTop_l', 'wTop_r', 'pweir');
