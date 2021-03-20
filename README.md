# scmutils-stirling-lagrangian
Simulation of a Stirling engine in MIT Scheme using the scmutils library. Some of the functions in the scmutils library were modified to support path dependent Lagrangians, which are needed to simulate heat engines. There are two downsides of using the Lagrangian in this manner: (1) Minimizing the action of a path dependent Lagrangian is slow to compute due to the need to compute an integral within the Lagrangian. (2) One cannot set the initial velocity of the piston directly, but rather by modifying the end conditions.

Screenshots:

Close, but Wrong

The results are what one would expect if the engine's initial condition is a non-zero velocity. The temperature of the gas actually drops below the temperature of the cold reservoir initially as the piston pulls a vacuum, and the temperature rises above that of the hot reservoir when the piston compresses. Note that the volume in the cylinder is decreasing after the crank position reaches pi.

![alt text](https://github.com/jtmayer/scmutils-stirling-lagrangian/blob/main/close-but-wrong.png?raw=true)
