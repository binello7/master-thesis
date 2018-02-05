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
## Created: 2018-02-03

clear all
close all
pkg load dataframe

load ('indexes_table.dat');
load ('qt_bbound.dat');
load ('qt_bchannel.dat');
load ('parameters.dat');

nExp = length (qt_bbound);
#nExp = 6;


dt = 30;


figure (1)
colr = pink(18);
for n = 1:nExp
  t = 1:saved_states(indexes_table(n,3));
  t = t * dt;
  leg{n} = sprintf ('Exp #%d', n);
  hold on
  h = plot (t, qt_bbound{n});
  set(h,'color',colr(i,:))
  hold off
endfor

legend (gca, leg{:});


#figure (2)
#for n = 1:nExp
#  t = 1:saved_states(indexes_table(n,3));
#  t = t * dt;
#  hold on
#  plot (t, qt_bchannel{n});
#  hold off
#endfor

#legend (gca, leg{:});


