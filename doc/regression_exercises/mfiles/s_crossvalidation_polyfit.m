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
## Created: 2018-01-24

close all
dataFolder = 'data';
fname = @(s) fullfile ('..', dataFolder, s);

dataFile = fname ('interpolation1D_poly1.dat');

data = load (dataFile);

X = data(:,1);
Y = data(:,2:end);

plot (X, Y(:,1), 'bo', X, Y(:,2), 'rx')
axis tight
