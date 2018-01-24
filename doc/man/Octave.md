# Octave: useful functions and functionalities


## Notes
* fflus???
* stdout???
* quad??
* fsolve??

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
* ``.'``: transpose
* ``'``: conjugate transpose (if not a complex equivalent to ')
* ``~``: if a function returns more than one parameter, assign it to the unwanted ones. This value is not returned but it is still computed!!
* ``!``: logical _not_ operator
* ``~``: logical _not_ operator
* ``@``:

## Format conversion specifications
* ``%g``: general (any number)
* ``%s``: string
* ``\n``: new line
* ``\t``: tab character

## Packages management
* ``pkg list``: list all installed packages
    - ``... -forge``: list all package available on _SourceForge_
* ``pkg install pkgname-X.X.X.tar.gz``: install the package _pkgname-X.X.X.tar.gz_
* ``pkg describe pkgname``: show a description of the package
    - ``... -verbose pkgname``: add a list of all functions implemented und _pkgname_
* ``pkg uninstall pkgname``: uninstall an installed package _pkgname_
* ``pkg load pkgname``: loads the package _pkgname_ for use within _Octave_
* ``pkg unload pkgname``: unloads the previously loaded package _pkgname_

## General functions
* ``doc`` _FunctionName_: returns the documentation of _FunctionName_
* ``help`` _FunctionName_: returns the help for the function _FunctionName_
* ``type`` _FunctionName_: shows the source code of the function _FunctionName_
* ``lookfor`` _SomeText_: looks for _SomeText_ in the help of every Octave
    function
* ``demo`` _FunctionName_: launches the demo for the function _FunctionName_
* ``test`` _FunctionName_: perform the tests for the function _FunctionName_
* ``who``: show the variables currently saved in the workspace
* ``whos``: showa a detailed view of the variables currently in the workspace

## Array Manipulation Functions
* ``flipud (X)``: flips matrix upsidedown (vertically)
* ``repmat (A, m, n)``: form a block matrix of size m by n, with a copy
    of matrix A as each element
* ``horzcat (mat1, mat2, ..., matN)``: horizonltally concatenates matrices. 
    Matrices must have the same vertical length.
* ``vertcat (mat1, mat2, ..., matN)``: vertically concatenates matrices. 
    Matrices must have the same horizontal length.
* ``unique (X)``: Returns the unique elements of X sorted in ascending order.
    X can be a matrix or a cell array of strings.
* ``find (X)``: return a vector of indices of nonzero elements of a matrix, as
    a row if X is a row vector or as a column otherwise.
* ``prepad (X, L, C)``: Prepend the scalar value C to the vector X until it
    is of length L. If C is not given, a value of 0 is used.


## Struct Functions
* fieldnames (_MyStruct_): returns the fieldnames of the struct _MyStruct_
* numfields (_MyStruct_): returns the number of fields of the struct _MyStruct_

## Strings Manipulation Funcitons
* ``strcat (s1, s2,... sN)``: returns the horizontal concatenation of the sN strings
* ``strcmp (s1, s3)``: returns 1 if s1 and s2 are the same, 0 if not
* ``strjoin (CellStringArray, Del)``: joins the elements of the cell string array into one single string using _Del_ as delimiter

## Functions to read data
* ``textscan``: read data from a text file or string
* ``load``: automatically loads the variables saved to a file by the function ``save``

## Functions to write data
* ``save ('filename.ext', 'datamatrix')``: save the array _datamatrix_ with default header to _filename.ext_
* ``fputs (fid, str)``: writes the string _str_ to the file _fid_ the way it is. No need to worry about special characters (%, \, ...)

## Folders and files management functions
``fullfile``: builds complete file names from separate parts

## Interpolation functions
* ``interp1 (x, y, xi)``: perform a one-dimensional interpolation
    - ``pp = interp1 (..., 'pp')``: if _pp_ is provided no _xi_ have to be given
      to the function. The function returns then a piecewise polynomial object. 
      The object can later be used with ``ppval`` for evaluation


## Evaluation functions
* ``ppval (pp, xi)``: evaluate the piecewise polynomial structure _pp_ at
    the points _xi_
* ``polyval (P, X)``: evaluate the polynomial P at the specified values of X.
    P is a vector made of the coefficients of the polynomial.

## Plot and related functions
* ``plot``: line plot in 2D
* ``quiver``: plots vector field
* ``mesh``: plots a mesh in 3D
* ``surf``: plots a surface in 3D
* ``view (az, el)``: specifies the plot view point to an azimuth _az_ and 
    elevation _el_
    * ``[az el] = view ()``: get the current figure view
* ``shading`` interp: interpolates the plot color
* ``colormap`` _ColormapName_: sets the plot's colormap to _ColormapName_
* ``hold``: to retain / let go the current figure
* ``gcf``: get current figure
* ``reshape``: reshapes a vector under a defined matrix form
* ``meshgrid``: given x and y spacing vectors produces a node points matrix

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


