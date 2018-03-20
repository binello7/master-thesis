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
## Created: 2018-01-21

close all
pkg load optim

## Load the variables
# load variables if not present in workspace
load ('input_Q.dat');
load ('extracted_data.dat');

i = 1;
## Remove unusable experiments
while i <= size (H)(2)
  if weircenter_head(i) < 0.3
    weircenter_head(i) = [];
    Qin(i)             = [];
    H(:,i)             = [];
    HZ(:,i)            = [];
    h0(i)              = [];
    v0(i)              = [];
  endif
  i+=1;
endwhile

## Input data
Qin   = abs (Qin);
h0    = h0 - weir_height;


## Generate the plots
fontsize1 = 10;#13;
fontsize2 = 11;#14;
#-------------------------------------------------------------------------------
# plot 1: longitudinal profile for the 25 experiments
i1 = 150; i2 = 261;
Y = flipud (Y);
plt_span = i1:i2;
figure (1)
plot (Y(plt_span), Z(plt_span), '-k', 'linewidth', 3);
hold on
plot (Y(plt_span), water (Z(plt_span), HZ(plt_span,:)));
hold off
axis equal
l1 = xlabel ('y / m', 'fontsize', fontsize2);
ylabel ('h / m', 'fontsize', fontsize2);
annotation ('textarrow', [0.4 0.45], [0.8 0.8], 'string', ' flow direction', ...
            'color', 'b', 'headlength', 6, 'headwidth', 6, 'fontsize', fontsize2);
set (gca, 'fontsize', fontsize1);
print ('free_surfaces.png', '-r300');

#-------------------------------------------------------------------------------
# plot 2: Q - h relation for the 25 experiments
figure (2)
plot ([0 Qin], [0 h0], 'bo', 'markerfacecolor', 'b')
xlabel ('Q / m^3/s', 'fontsize', fontsize2);
ylabel ('h_{w} / m', 'fontsize', fontsize2);
axis tight
set (gca, 'fontsize', fontsize1);
pause (0.5)
print ('simulation_results.png', '-r300');


