function [obj, design] = evaluateTurbine(varargin)
% This function evaluates a turbine design, given a set of properties in a
% format suitable for optimisation using the metaheuristics code by Yang.
% 1 Input:  x - either a string that contains the ONE aerofoil type to be
%               used, or else a cell array that contains the aerofoil type
%               at each cross-section.
%            -- OR --
% 4 Inputs: for aerofoil information already found from elsewhere
%           Inputs must be in correct order. 
%           1. x = 1 x n matrix containing the sequence number (1...k) of the 
%                aerofoil to be used at each section. n == nSections
%           2. CL = 1 x k matrix containing lift coefficient for each of k
%           aerofoils
%           3. CD = 1 x k matrix containing drag coefficient at optimal angle
%           of attack for each of k aerofoils.
%           4. alpha = 1 x k matrix containing optimal angle of attack for
%           each of k aerofoils
% Outputs:  obj = objective value of interest, to be defined for the application.
%           design = structure with turbine design features, specifically
%           r = cross-sectional radii
%           chord = chord length
%           Cp = power coefficient
%           alpha = angle of attack
%           beta = local twist angles

% Jack Collinson, jcol704

% Constants (to go into params)
global Vu RPM rho torque eta nSections clearance B Re

if nargin == 1
    x = varargin{1};
    if isa(x, 'cell')
        assert(nSections == length(x))
    end
    
    % Get aerofoil data.
    % TODO using callXfoil() calls.
    
    alpha = 10;
    [pol, foil] = callXfoil(x,alpha,Re,0);
    alpha = pol.alpha;
    Cl = pol.CL;
    Cd = pol.CD;
    
    
elseif nargin == 4
    % Aerofoil info already pre-generated and is read in.
    x = varargin{1};
    assert(nSections == length(x));
    LiftCoeffs = varargin{2};
    DragCoeffs = varargin{3};
    Alphas = varargin{4};
    
    Cl = LiftCoeffs(x); % Lift coeff for EACH cross-section
    Cd = DragCoeffs(x); % Drag coeff for EACH cross-section
    alpha = Alphas(x); % angle of attack for each aerofoil at EACH cross-section
else
    error("Incorrect number of inputs")
end

% BEM Calculations

% Calculate overall rotor radius
Cp_guess = 0.5;
R = sqrt((2*torque*RPM)/(Cp_guess*eta*rho*Vu^3));

% Calculate tip speed ratio
tsratio = (RPM*2*pi*(1/60))*R/Vu;

% Set wake rotation binary if not defined
if ~exist('wakerotation', 'var')
    wakerotation = false;
end 

% Set tip loss binary if not defined
if ~exist('tiploss','var')
    tiploss = false;
end

% Set initial Cp and Cp_old
Cp = Cp_guess;
Cp_old = 0;

% Iterative scheme
while abs(Cp - Cp_old) > 1e-4
    % For loop to go through elements (n) of the blade
    n = 4;
    % Start with initial a and a'
    a = 1/3;
    a_dash = 0;
    
    for i = n:-1:1  
        % Calculate r
        r = (i*(R-clearance))/n + clearance;

        % Calculate local wind angle phi and chord length c
        if wakerotation
            phi = (2/3)*atand(1/tsratio);
            c = (8*pi*r*(1-cosd(phi)))/(B*Cl);
        else
            phi = atand((2)/(3*tsratio));
            c = (8*pi*r*sind(phi))/(B*Cl*3*tsratio);
        end
        fprintf("c = %d\n",c);
        % Calculate new a and a'
        Cn = Cl*cosd(phi) + Cd*sind(phi);
        Ct = Cl*sind(phi) - Cd*cosd(phi);
        f = (B*R-B*r)/(2*r*sind(phi));
        F = (2/pi)*acos(exp(-f));
        solidity = (B*c)/(2*pi*r);

        if tiploss
            a = (solidity*Cn)/(4*F*sind(phi)^2 + solidity*Cn);
            a_dash = (solidity*Ct)/(4*F*sind(phi)*cosd(phi) - solidity*Ct);
        else
            a = (solidity*Cn)/(4*sind(phi)^2 + solidity*Cn);
            a_dash = (solidity*Ct)/(4*sind(phi)*cosd(phi) - solidity*Ct);
        end        
        fprintf("solidity = %d\n",solidity);
        fprintf("a = %d\n\n",a);
        % Calculate tangential load
        load = (Ct*c*rho*Vu^2*(1-a)^2)/(2*sind(phi)^2);
        %fprintf("Load = %d\n", load);
        
        element(i).r = r;
        element(i).load = load;
        element(i).alpha = alpha;
        element(i).beta = phi - alpha;
        element(i).c = c;
        
    end
    
    % Integrate numerically to find the total torque Q
    Q = 0;
    for i = 1:n-1
        Q = Q + trapz([element(i).load*element(i).r element(i+1).load*element(i+1).r]);    
    end
    Q = Q*B;
    
    % Find the power extracted, power available, and Cp
    Pe = Q*(RPM*2*pi*(1/60));
    Pt = 0.5*rho*pi*R^2*Vu^3;
    Cp_old = Cp;
    Cp = Pe/Pt;
    
end

% Set the objective to be returned to be Cp
obj = Cp; 

% Set the design struct to be returned
design = struct('r',[],'c',[],'Cp',0,'alpha',0,'betas',[]);
for i = 1:n
   design.r = [design.r element(i).r];
   design.c = [design.c element(i).c];
   design.Cp = Cp;
   design.alpha = element(i).alpha;
   design.betas = [design.betas element(i).beta];
end

return