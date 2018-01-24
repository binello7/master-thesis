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

## -*- texinfo -*-
## @defun {@var{outarg} =} funcname (@var{inarg}, @dots{})
## @defunx {@var{outarg2} =} funcname (@var{inarg2}, @dots{})
## Oneliner
##
## Explanation usage 1
##
## Explanation usage 2
##
## @seealso{func1, func2}
## @end defun


function [ss3 ss4] = exchange_elements (ss1, ss2, nel)

  n1 = length (ss1);
  n2 = length (ss2);

  if nel > n1 || nel > n2
    error ('Octave:invalid-input-arg', 'The number of elements to exchange has to be smaller then the datasets')
  endif

  nl = min (n1, n2);
  el = randperm (nl)(1:nel);

  tmp = ss1(el,:);
  ss1(el,:) = ss2(el,:);
  ss2(el,:) = tmp;

endfunction
