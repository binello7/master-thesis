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
## Created: 2018-01-24

close all
rand ('state', double ('abracadabra'));
randn ('state', double ('abracadabra'));

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

## Resposes
#
function V = responses (t, p)
  nT = size(t, 1);
  nP = size(p, 2);
  V = zeros (nT, nP, 4);
   
  V(:,:,1) = 1./sqrt(p(1,:).*t) .* (t > 0) + ones(nT,nP) .* (t<=0);
  V(:,:,2) = sin (2 * pi * p(2,:) .* (t - p(3,:)));
  V(:,:,3) = t.^2 .* exp ( - p(4,:) .* (t - p(5,:)).^2);
  V(:,:,4) = ( 1 - tanh (p(6,:) .* (t - p(7,:)))) / 2;

  V = squeeze (V);
endfunction

## Mixtures
#
nT = 100;
T = 6;
t  = linspace (0, T, nT).';

nS        = 10;
A         = round (10 * randn(4, nS) ) / 10;
A(abs(A)<=0.6) = 0;
A .*= [8 2 0.1 5].';
P = 1 + 4*round (1e2 * rand(7, nS)) * 1e-2;
P .*= [1 0.2 1 1/2 T/6 1 T/8].';
P(7,:) += 0.15*T;

V = responses (t, P);

y = zeros (nT, nS);
for i = 1:nS
  y(:,i) = squeeze(V(:,i,:)) * A(:,i);
endfor

savedata (fname('mixture'), [t y])

figure (1)
plot (t, y,'-')
axis tight

figure(2)
for i=1:4
  subplot (2,2,i);
  plot (t, V(:,:,i).*A(i,:));
  axis tight
endfor

