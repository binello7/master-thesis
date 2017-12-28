# Notes - Gaussian Processes presentation

* Machine learning: learning from data

## The learning problem
*Assume: we have a function linking input and output (functional relationship)
*Choose: chose a set of hypothesis
*Equifinality

## General
* Interpolation problem: go over the points, through the points, not close to
* Matrix inversible: determinant different from zero, rank = matrix size
* Moore-Penrose pseudoinverse
* Rank: number of linearly independent rows. If rank not equal lines number then the determinant is 0 and the matrix is not inversible.
* Rows: feature vectors
* columns: basis functions
* data view / functional view → Gaussian processes easier to understand in functional view
* Grammian matrix
* Kernel trick
* By selecting the covariance functions we implicitly select features for our model
* Question: how do we choose the covariance function? We have to have prior knowledge on what generated the data
* Rasmussen, Gaussian processes for machine learning
* null space??
* GPML?? → Gaussian Processes for Machine Learning
* Octave: sinc = sin(x) / x
* Octave: rcond
* Octave: eigs: eigenvalues of a matrix
* Octave: pinv: pseudoinverse
* Octave: eps: machine precision
* Octave: imagesc
* you can do neural networks with gaussian processes, but only infinite ones, not finite ones
* working in a Fourier space and not in a polynomial space (covNNone)
* Covariance matrix
* emulator of simulator: advantages. 1. simulator has no error! It is not a measure, it’s a computation. 
* Theoretically it is possible to find the perfect emulator → no error in comparison with simulator. But the computational cost would be higher than the simulator itself!


