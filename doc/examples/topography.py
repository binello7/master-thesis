from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
from matplotlib import cm
from matplotlib.ticker import LinearLocator, FormatStrFormatter
import numpy
import math



a = [1, 2, 3, 4, 5]
c = [10, 11, 12, 13, 14]
a = numpy.array(a)
b = 2
print(a + b)
print(a + c)
d = numpy.array([a,c])
print(d)



### PARAMETERS ###

# GRID GEOMETRY #
n = 200 # [-] number of cross-sections
sections_spacing = 100 # [m]

# CHANNEL GEOMETRY #
# every cross section is composed of 9 points
B = 8 # [m] river bed
br = 1
bl = 1
Pr = 20
Pl = 20
er = 2
el = 2
H1 = 2 # [m] channel height
H2 = 4 # [m] embankment height
z_0 = 1500

J = 0.01 # [-] channel slope
alpha = math.atan(J) # [rad] channel angle
x_proj = math.sin(alpha) # [-] x projection factor
z_proj = math.cos(alpha) # [-] z projection factor




x0 = numpy.array([(H1+H2) * x_proj, H1 * x_proj, H1 * x_proj, 0, 0, 0, H1 * x_proj, H1 * x_proj, (H1+H2) * x_proj]);
y0 = numpy.array([B/2 + H1/bl + Pl + H2/el, B/2 + H1/bl + Pl, B/2 + H1/bl, B/2, 0, -B/2, -(B/2 + H1/bl), -(B/2 + H1/bl + Pl), -(B/2 + H1/bl + Pl + H2/el)]);
z0 = numpy.array([z_0 + (H1 + H2) * z_proj, z_0 + H1 * z_proj, z_0 + H1 * z_proj, z_0, z_0, z_0, z_0 + H1 * z_proj, z_0 + H1 * z_proj, z_0 + (H1 + H2) * z_proj]);


x1 = x0 + sections_spacing * math.cos(alpha)
y1 = y0
z1 = z0 - sections_spacing * math.sin(alpha)



# X = numpy.arange(-5, 5, 0.25)
# Y = numpy.arange(-2,2,.25)
X = numpy.concatenate((x0,x1), axis=0)
Y = numpy.concatenate((y0,y1), axis=0)
Z = numpy.concatenate((z0,z1), axis=0)


# X, Y = numpy.meshgrid (X, Y)
# Z = numpy.sqrt(X**2 + Y**2)

# print(X)
# print(Y)
# print(Z)


fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')
ax.scatter(X, Y, Z)
plt.show()
