# Octave: useful functions and functionalities


## Notes
fflus???
stdout???

## Behaviour
* if A is a matrix m x n, ``A(:)`` is a column vector where the columns of A were concatenated one after each other from 1 to n

## Miscellaneous
* ``eps``: smallest difference between two adjacent numbers in the machine's floating point system.
* ``sqrt(eps)``: smallest number in Octave

## Classes
* double
* struct
* inputParser

## Operators
* .': transpose
* ': conjugate transpose (if not a complex equivalent to ')
* ~: if a function returns more than one parameter, assign it to the unwanted ones. This value is not returned but it is still computed!!
* @:

## Format conversion specifications
* ``%g``: general (any number)
* ``%s``: string
* ``\n``: new line
* ``\t``: tab character

## Packages management
* ``pkg list``: list all installed packages

## General functions
* ``doc`` _FunctionName_: returns the documentation of _FunctionName_
* ``help`` _FunctionName_: returns the help for the function _FunctionName_
* ``type`` _FunctionName_: shows the source code of the function _FunctionName_
* ``lookfor`` _SomeText_: looks for _SomeText_ in the help of every Octave function
* ``demo`` _FunctionName_: launches the demo for the function _FunctionName_
* ``test`` _FunctionName_: perform the tests for the function _FunctionName_
* ``whos`` _VariableName_: shows the properties of the variable _VariableName_

## Array Manipulation Functions
* flipud: flips a vector (vertical!) upsidedown
* ``repmat (A, m, n)``: Form a block matrix of size m by n, with a copy of matrix A as each element
* unique (X): Returns the unique elements of X sorted in ascending order

## Struct Functions
* fieldnames (_MyStruct_): returns the fieldnames of the struct _MyStruct_
* numfields (_MyStruct_): returns the number of fields of the struct _MyStruct_

## Strings Manipulation Funcitons
* strcat (s1, s2,... sN): returns the horizontal concatenation of the sN strings
* strcmp (s1, s3): returns 1 if s1 and s2 are the same, 0 if not

## Functions to read data
* ``textscan``: read data from a text file or string

## Functions to write data

## Plot and Related Functions
* ``plot``: line plot in 2D
* ``quiver``: plots vector field
* ``mesh``: plots a mesh in 3D
* ``surf``: plots a surface in 3D
* ``view (az, el)``: specifies the plot view point to an azimuth _az_ and elevation _el_
* ``shading`` interp: interpolates the plot color
* ``colormap`` _ColormapName_: sets the plot's colormap to _ColormapName_
* ``hold``: to retain / let go the current figure
* ``gcf``: get current figure
* ``reshape``: reshapes a vector under a defined matrix form
* ``meshgrid``: given x and y spacing vectors produces a node points matrix

## Folders and files management functions
``fullfile``: builds complete file names from separate parts

## Errors management functions
* ``error_ids``: returns the Octave standard error ids
* ``print_usage ()``: prints on the terminal the function documentation
* ``error``: displays an error message and stops the file execution

## Functions check blocks
Function tests have to be devided into block beginning with either:
* ``%!test``
* ``%!testif HAVE_XXX``: check block only if Octave was compiled with feature HAVE_XXX
* ``%!xtest``: tests that should work but are known to fail. Test is run, failure reported, but running of tests is not aborted
* ``%!assert (x, y, tol)``: shorthand for ``%!test assert (x, y, tol)``
* ``%!demo``: tests requiring user interactions
* ``%!error``: check for correct error message
* ``%!warning``: check for correct warning message
* ``%!#``: comment. Ingore everything within the block
* ``%!shared x, y, z``: the variables _x, y, z_ are shared between the different test block
* ``%!function``: define a function for use in multiple tests 
* ``%!endfunction``: close a function definition lines beginning with ``%!<whitespace>`` are part of the preceeding block

## Debugging
* ``keyboard``: enters debugging mode at the line where _keyboard_ was inserted
* ``dbquit`` : to quit the debugging mode
* ``dbnext``: goes on to the new code line where some code is written
* ``dbcont``: goes on to the new stop point (``keyboad``)


