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
## Created: 2018-03-11



h1 = linspace (0, 2, 10);
h2 = linspace (0, 2, 200);
d = 5e-2; #m

A = (d/2)^2 * pi;
c = 0.8;

f_Q = @(h) c * A * sqrt (2 * 9.81 * h) * 10^3;

Q1 = f_Q (h1);
Q2 = f_Q (h2);

figure (1)
plot (h1, Q1, 'ob', 'markerfacecolor', 'b');
xlabel ('h [m]', 'fontsize', 14);
ylabel ('Q [l/s]', 'fontsize', 14);
set (gca, 'fontsize', 13)

print ('img/tank_points.png', '-r300')

pause (0.5)
hold on
h = plot (h2, Q2, 'k--');
set (h, 'linewidth', 1)
hold off
pause (0.5)
print ('img/tank_line.png', '-r300')



