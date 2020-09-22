alphas = 0:1:15; % You can change this
Re = 60000; % You can change this too

% Define anonymous function wrapper, as ga() only allows one vector of inputs.
% Note we are maximising, but MATLAB's MH minimises.
fun = @(X) -1*testNACAaerofoil(X, alphas, Re);

% Appropriate parameters to ensure things don't take too long
options = optimoptions('ga','PopulationSize', 5, 'MaxGenerations', 10, ...
     'PlotFcn', {@gaplotbestf, @gaplotscorediversity});
LB = [0 0 12]; % Lower bounds
UB = [7 6 30]; % Upper bounds
% 2nd-to-last input are the indices of integer vars
[x fval] = ga(fun,3,[],[],[],[],LB,UB,[],[1 2 3],options) 