function objective = testNACAaerofoil(X, alphas, Re)
% Function evaluates the performance of a NACA aerofoil for the
% purposes of 'robust' performance in a turbine design.
% Inputs: 	X = 3 element vector, containing the 3 numeric elements
%				that define a NACA aerofoil.
%			alphas = range of angles to consider
%			Re = target Reynolds number for design
% Output: 	objective = objective function used in Metaheuristic.
%
% Name: Jack Collinson      UPI: jcol704

% Combine to get a string
aerofoil = strcat('NACA', num2str(X(1)), num2str(X(2)), num2str(X(3)));

pol = callXfoil(aerofoil, alphas, Re, 0);
[~, idx] = max(pol.CL./pol.CD);
Cl = pol.CL(idx);
Cd = pol.CD(idx);
alpha = pol.alpha(idx);
ratio = Cl/Cd; % We maximise this in BEM.

% Test for constant Re at small perturbations of angle
% Loop over a range

n = 3; % Max number of indices away from optimal
a = min(idx-1,n);
b = min(size(alphas,2) - idx - 1,n);
ratios = zeros(1,a+b+1);
for i = idx-a:1:idx+b
    ratios_angle(i-idx+a+1) = pol.CL(i)/pol.CD(i);
end
ratios_angle = ratios_angle - ratio;
% Test for behaviour at fixed angle for different Re.
% We test a small range of alphas around the optimal to
% allow for interpolation to occur, if xfoil does not 
% converge at optimal angle.

minRe = max(10000, Re - 20000); % Must be less than input Re
maxRe = Re + 20000; % Must be more than input Re
gap = 10000; 
i = 1;
for j = minRe:gap:maxRe
    pol = callXfoil(aerofoil, alpha-2:0.5:alpha+2, j, 0); 
    Cl = pol.CL(pol.alpha == alpha);
    Cd = pol.CD(pol.alpha == alpha);
    ratios_Re(1,i) = j;
    ratios_Re(2,i) = Cl/Cd;
    i = i + 1;
end
ratios_Re = ratios_Re - ratio;
% Set weights for objective function
%
% The weights_angles array applies to ratios_angle, with length n, where 
% element 2 is the weight for ratios 1 index from the optimal angle etc
%
% The weights_Re array applies to ratios_angle, with length
% (maxRe-minRe)/2*gap, where element 2 is the weight for ratios 1*gap
% distance from the optimal Re
weights_angle = [1 0.9 0.8 0.7 0.6]; % Simple linear for n <= 5
weights_Re = [1 0.9 0.8 0.7 0.6 0.5 0.4 0.3 0.2 0.1]; % Simple linear
    
% Values for objective function
% angle_pen, the penalty for ratio variability due to angle change
% Re_pen, the penalty for ratio variability due to Re change
% *_pen_weights change the relative importance of each penalty, [0...1]
angle_pen_weight = 2;
Re_pen_weight = 2;

angle_pen = 0;
for i = 1:size(ratios_angle,2)
    if i <= a    
        index = abs(-a+i-2); % index for weights_angle
    else
        index = -a+i;
    end
    angle_pen = angle_pen + abs(ratios_angle(i)*weights_angle(index));
end
angle_pen = angle_pen/size(ratios_angle,2); % Normalize

Re_pen = 0;
for i = 1:size(ratios)
    if i <= (Re - minRe)/gap + 1     
        index = abs(-(Re - minRe)/gap - 2 + i); % index for weights_Re
    else
        index = -(Re - minRe)/gap + i;
    end    
    Re_pen = Re_pen + abs(ratios_Re(2,i)*weights_Re(index));
end
Re_pen = Re_pen/size(ratios_Re,2); % Normalize



% The optimal ratio plus the penalties for variability, maximizing
objective = ratio - angle_pen_weight*angle_pen - Re_pen_weight*Re_pen;

return

