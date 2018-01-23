## Copyright (C) 2018 Juan Pablo Carbajal
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program. If not, see <http://www.gnu.org/licenses/>.

## Author: Juan Pablo Carbajal <ajuanpi+dev@gmail.com>
## Created: 2018-01-22

## 1D inteprolation data generator
# 
close all
randn ('state', double('abracadabra'))

## Data saving function
#
function savedata (fname, data)
  fid = fopen (fname, 'wt');
  header = ['# X' sprintf(', Y%d', 1:size(data, 2)-1)];
  fprintf (fid, "%s\n", header);
  fclose (fid);
  save ('-ascii', '-append', fname, 'data');
  printf ('Saved to %s\n', fname);
endfunction
datapath = fullfile ('..','data');
fname = @(name) fullfile (datapath, sprintf ('interpolation1D_%s.dat', name));

## Polynomial data
#
max_order = 5;
nX        = (max_order + 1) + 5;
x         = linspace (-1, 1, nX).' + 2 / nX * 0.4 * randn (nX, 1);
o         = randperm (nX);
x         = x(o);

y      = (x + 0.8) .* x.^2 .* (x - 0.5) .* (x - 0.9); # 5th order
y(:,2) = polyval ([0 4 8 0 -4 0], x); 
figure(1, 'name', 'Direct')
plot (x, y,'o');
axis tight
grid on
savedata (fname('poly1'), [x y]);

## Warped output
# 
nX        = 25;
x         = linspace (-1, 1, nX).' + 2/nX * 0.4 * randn (nX, 1);
o         = randperm (nX);
x         = x(o);

y = exp ( 3 * (x - 0.5) .* x .* (x - 1) );
figure(2, 'name', 'Warped output')
plot (x, y,'o');
axis tight
grid on
savedata (fname('warp1'), [x y]);

## Warped input
# 
nX        = 25;
x         = linspace (-1, 1, nX).' + 2/nX * 0.4 * randn (nX, 1);
o         = randperm (nX);
x         = x(o);

xw = tanh ( 3 * x);
y  = 3 * (xw + 0.6) .* xw .* (xw - 1);
figure(3, 'name', 'Warped input')
plot (xw, y,'o', x, y, 'x');
axis tight
grid on
savedata (fname('warp2'), [x y]);


