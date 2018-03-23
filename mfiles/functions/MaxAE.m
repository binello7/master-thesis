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
## Created: 2018-03-12


## -*- texinfo -*-
## @defun {@var{err} =} MaxAE (@var{y_sim}, @var{y_obs})
## Computes the maximum absolute error (MaxAE)
## @end defun

function err = MaxAE (y_sim, y_obs)
  err = max (abs (y_sim(:) - y_obs(:)));
endfunction
