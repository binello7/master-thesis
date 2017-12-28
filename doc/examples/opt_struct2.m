## Copyright (C) 2017 JuanPi Carbajal
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

## -*- texinfo -*- 
## @deftypefn {} {@var{retval} =} opt_struct (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: JuanPi Carbajal <juanpi@cachi>
## Created: 2017-12-01

function opt = opt_struct2 (varargin)
  parser = inputParser ();
  parser.addParamValue ('Length', 1, @(x) x > 0 && isscalar(x));
  parser.addParamValue ('Gravity', 9.8, @(x) x > 0 && isscalar(x));
  parser.addParamValue ('Mass', 1, @(x) x > 0 && isscalar(x));

  parser.parse (varargin{:});
  
  opt = parser.Results;

endfunction

%!demo
%! p = opt_struct ();
%!
%! printf ("Simulating ...\n"); fflush (stdout);
%! disp (p);

%!demo
%! l = linspace (1,1.5,3);
%! for i = 1:3
%!   p = opt_struct2('length', l(i));
%!   printf ("Simulating length %f\n", p.Length); fflush (stdout);
%! endfor

%!demo
%! p = opt_struct2 ();
%!
%! l = linspace (1,1.5,3);
%! for i = 1:3
%!   p.Length = l(i);
%!   printf ("Simulating length %f\n", p.Length); fflush (stdout);
%! endfor

%!test
%! p = opt_struct2 ();
%! p_unsafe = p; p_unsafe.Length = 2;
%! p_safe   = opt_struct2 ('length', 2);
%! assert (p_unsafe, p_safe);

%!error opt_struct2 ('length', -2);

