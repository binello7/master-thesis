## Copyright (C) 2018 - Sebastiano Mario Rusca
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

## Author: Sebastiano Mario Rusca <sebastiano.rusca@gmail.com>
## Created: 2018-03-11

## -*- texinfo -*-
## @defun {@var{err} =} rmse (@var{sim}, @vr{obs})
## Computes the root mean squared error (rmse)
##
## @end defun


function err = rmse (y_sim, y_obs)
  y_sim = y_sim(:);
  y_obs = y_obs(:);
  N = length (y_obs);
  err = sqrt (1/N * sum ((y_sim - y_obs).^2));
endfunction
