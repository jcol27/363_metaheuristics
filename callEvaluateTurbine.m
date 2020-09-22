% Example calls to evaluateTurbine()
% Defines global vars required for optimisation.

global Vu RPM rho torque eta nSections clearance B Re

Vu = 10 * 0.51444;  % Design speed, e.g. 10 knots per hour
RPM = 140;          % Target RPM
rho = 1.29;         % Density of air
torque = 3.25;      % Target torque, from datasheet
eta = 1;            % System efficiency
nSections = 15;
clearance = 0.1;    % Radius of hub + any further distance with no blade section allowed.
B = 1;              % Number of blades
Re = 60000;         % Approximate Reynolds number for design

[obj, design] = evaluateTurbine('NACA0010');

testArray = {'NACA0015', 'NACA0015', 'NACA0015', 'NACA0015', 'NACA0015', 'NACA0015', 'NACA0015', 'NACA0015', ...
     'e176.dat', 'e176.dat', 'e176.dat', 'e176.dat', 'e176.dat', 'e176.dat', 'e176.dat'};
[obj, design] = evaluateTurbine(testArray);

CL = [1.3054    0.8773    0.6231];
CD = [0.0126    0.0110    0.0123];
Alphas = [0.0873    0.0785    0.0873]; % in radians
x = [1 1 1 1 2 2 2 2 2 2 3 3 3 3 1];

[obj, design] = evaluateTurbine(x, CL, CD, Alphas);
