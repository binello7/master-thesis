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

function opt = opt_struct ()
  opt = struct ();
  
  ## Default values
  opt.Length  = 1;        # Length in meters
  opt.Gravity = 9.8;      # accel of gravity in m/s^2
  opt.Mass    = 1;        # mass in kilograms

endfunction

%!demo
%! p = opt_struct ();
%!
%! printf ("Simulating ...\n"); fflush (stdout);
%! disp (p);

%!demo
%! p_default = opt_struct ();
%! p_heavy   = p_long = p_mars = p_default;
%! p_heavy.Mass   = 100;
%! p_long.Length  = 10;
%! p_mars.Gravity = 0.96 * p_mars.Gravity;
%!
%! printf ("Simulating ...\n"); fflush (stdout);
%! disp (p_heavy)
%! printf ("Simulating ...\n"); fflush (stdout);
%! disp (p_long)
%! printf ("Simulating ...\n"); fflush (stdout);
%! disp (p_mars)

%!demo
%! p = opt_struct ();
%!
%! l = linspace (1,1.5,3);
%! for i = 1:3
%!   p.Length = l(i);
%!   printf ("Simulating length %f\n", p.Length); fflush (stdout);
%! endfor
