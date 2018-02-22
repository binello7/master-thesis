=========================================
Notes & Solutions exercises 1D regression
=========================================


Cross-validation
~~~~~~~~~~~~~~~~

Linear filter
+++++++++++++
We will solve the problem with a *linear filter*

.. math::
    y(\mathbf{x}) = \sum_{j=1}^N w(y_j) \phi(\mathbf{x}, \mathbf{x}_j)
   
First using the function

.. math::
   \phi_{SE}(x,x_j) = \exp \left(-\frac{(x -x_j)^2}{2\sigma^2}\right)
   
For :math:`x = x_i` we solve

.. math:: 
   y(x_i) = \sum_{j=1}^N w(y_j) \phi(\mathbf{x}_i, \mathbf{x}_j) = y_i
   
For :math:`x_i = x_1` we have

.. math::
   y(x_1) = \sum_{j=1}^N w(y_j) \phi(\mathbf{x}_1, \mathbf{x}_j) = y_1

Written in matrix form:

.. math::
   \begin{bmatrix}
    y_1 \\
    \dots \\
    y_N \\
   \end{bmatrix}
   =
   \begin{bmatrix}
    \phi(x_1, x_1) & \dots & \phi(x_1,x_N) \\
    \dots & \dots & \dots \\
    \phi(x_N, x_1) & \dots & \phi(x_N,x_N) \\
   \end{bmatrix}
   \begin{bmatrix}
    w_1 \\
    \dots \\
    w_N
   \end{bmatrix}

The solution we are looking for is then:

.. math::
   \begin{bmatrix}
    w_1 \\
    \dots \\
    w_N
   \end{bmatrix}
   =
   \begin{bmatrix}
    \phi(x_1, x_1) & \dots & \phi(x_1,x_N) \\
    \dots & \dots & \dots \\
    \phi(x_N, x_1) & \dots & \phi(x_N,x_N) \\
   \end{bmatrix}^{-1}
   \begin{bmatrix}
    y_1 \\
    \dots \\
    y_N \\
   \end{bmatrix}
   
   
   