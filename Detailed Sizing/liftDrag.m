function ac = liftDrag(ac, Wi, V, h)
%% Lift coefficient, drag coefficient, L/D estimation function

%% Inputs
Sref = ac.wing.sw; % Planform wing area [ft^2]
e0 = 1.78 * (1 - 0.045 * ac.AR ^ 0.68) - 0.64; % Oswald Efficiency Factor

% Units conversion [knots -> ft/sec]
v = V*1.68781;

%% Atmosphere Conditions

% Atmosphere at loiter altitude (speed of sound, viscosity, density)
[~, ~, rho] = AtmosphereFunction(h);

% Dynamic pressure
q = 0.5*rho*v^2;

%% CL for flight conditions
CL = Wi/(q * Sref);

%% CD Buildup

% Induced Drag Coefficient
CDi = CL^2./(pi*ac.AR*e0); %* .7;


% Parasitic drag buildup
ac.CDi = CDi;
ac.CL = CL;
ac = parasiticBuildup(ac, V, h);



%% Total drag and L/D
CD = ac.CDi + ac.CD0;
ac.CD = CD;
ac.L_D = CL / CD;
ac.D = CD * q * Sref;

end