% AAE 451 - Team 7 - CoDR
% Code to generate constraint diagram for NASA Design Challenege RAM/UAM
% firefighting and transport vehicle
% Uses preliminary (basic) design algorithm from Raymer
% Database Values in this order: Bell XV-15, Uni of Maryland Excalibur,
% AugustaWestland AW609, Bell V-247, Bell V-280, Boeing MV22, NASA
% Conventional Tiltrotor Baseline, NASA Variable Diameter Tiltrotor
% (ascending gross weight)

% All calculations performed in English units

% We_W0 = [0.7362,0.6293,0.6253,0.5517,0.5857,0.8055,0.7040,0.7199];
% W0 = [13000,16145,16799,29000,30865,39500,48334,48883]; % lb
% W0_P = [2.2222,2.6908,6.5982,4.8333,4.4093,3.8610,2.3585,3.0581]; %lb/hp
% W0_S = [15.2,11,15.9,20.5133,16,20.9,18,11]; %lb/ft^2

%% Tiltrotor sizing results
MTOW = 32964; % lb, from complex, phase-based sizing code
engineHP = 4330; %hp, from selected engine
rhoAlt = 0.001756; % slug/ft3 @ 10,000 ft (altitude dominates temperature)
rhoSL = 0.002377;
sigma = rhoAlt/rhoSL;
Beta = 0.9; % weight fraction at instant in mission profile, 1 is full fuel + payload
Alpha = (rhoAlt/rhoSL)^0.8; % engine lapse rate, modern turboprop
W_SHelo = 13:30; % lb/ft2, continuous disk loading, x-axis of constraint diagram
W_SPlane = 30:110; % lb/ft2, continuous wing loading, x-axis of 2nd constraint diagram
MoM = 0.9; % ideal/actual power, 0.6-0.8 range
b = 3; % number of blades per rotor, V-280 value here
c = 1.75; % ft, chord of blades, result of Excalibur studies
r_blade = 14.5; % ft, radius of blade, V-280 value here
solidity = (b*c)/(pi*r_blade);
V_cruise = 422; % ft/s, (250 kts), lower end of range up to 473 (280 kts)
ROC = 50; % ft/s, 2/3 of max rate of climb demonstrated by V-280
f = 1.05; % fuselage downwash correction, guessing higher for tiltrotor
etaMech = 0.97; % mechanical efficiency
etaProp = 0.85; % proprotor efficiency in forward flight
D_q = 1.5*MTOW^(2/3); % tiltrotor empirical relationship based on frontal area
T80 = 0.8*MTOW; % want to cruise at 80% thrust req'd by VTOL
TMax = MTOW/0.8; % want MTOW to not exceed 80% of the available thrust (safety)
q = T80/D_q; % dynamic pressure
qBern = 0.5*rhoAlt*V_cruise^2; % dynamic pressure by Bernoulli
Oswald = 0.7; %0.5-0.8, Oswald efficiency
cd0 = 0.024; % guess
AR = 6.178; % aerodynamic analysis
%% Helicopter Constraint Diagram
Psl_W_hover = (Beta^1.5/Alpha)*(f^1.5/(550*etaMech*MoM*sqrt(2*rhoAlt)))...
    .*sqrt(W_SHelo); %Power loading for hover at altitude

Psl_W_vert = (Beta/(Alpha*550*etaMech)).*((f^1.5*sqrt(Beta))/(MoM*sqrt(2*rhoAlt))...
    .*sqrt(W_SHelo) + 0.5*ROC); %Power loading for vertical climb at altitude

Psl_W_level = (Beta/Alpha)*(V_cruise/(550*etaProp*etaMech)).*...
    ((q/Beta).*(cd0./W_SHelo + (Beta/q)^2.*W_SHelo./(4*Oswald)));
% Power loading for level flight at altitude using disk loading

Psl_W_climb = (Beta/Alpha)*(V_cruise/(550*etaProp*etaMech)).*...
    ((q/Beta).*(cd0./W_SHelo + (Beta/q)^2.*W_SHelo./(4*Oswald)) + ROC/V_cruise);
% Power loading in climbing forward flight using disk loading

figure(1)
%plot(W_SHelo,Psl_W_hover,W_SHelo,Psl_W_vert,...
%    W_SHelo,Psl_W_level,W_SHelo,Psl_W_climb)
plot(W_SHelo,Psl_W_hover,W_SHelo,Psl_W_vert)
hold on
yline((2*engineHP)/MTOW)
hold off
title('Power Loading P/W0 (hp/lb) vs Disk Loading W0/S (lb/ft2) @ Mountain Altitude')
%legend('Hover','Vertical Climb','Level Flight','Cruise-Climb','T64x2 Power Loading')
legend('Hover','Vertical Climb @ 50 ft/s','T406 Engine x2')
xlabel('Disk Loading lb/ft2')
ylabel('Power Loading hp/lb')

% right now this plot is dominated by level and cruise-climb flight because
% it's trying to reach those speeds using disk loading, helo mode, instead
% of wing loading, which must be considered separately - V-22 Osprey flies
% twice as fast as any helicopter!

%% Aircraft Constraint Diagram
Psl_W_TOC = (Beta/Alpha)*(V_cruise/(550*etaProp*etaMech)).*...
    ((qBern/Beta).*(cd0./W_SPlane + (Beta/qBern)^2/(pi*AR*Oswald).*W_SPlane)...
    + ROC/V_cruise); % Powerloading in SLUF at top-of-climb

VminP = sqrt((2*Beta/rhoAlt).*W_SPlane.*sqrt(1/(3*cd0*pi*AR*Oswald)));
CLminP = sqrt(3*cd0*pi*AR*Oswald);
CGR = 0.04; % 4% climb gradient

Psl_W_Crit = (Beta/Alpha)*(2/(550*etaProp)).*sqrt(2*Beta/(rhoAlt*CLminP).*W_SPlane).*...
    (CGR + cd0/CLminP + CLminP/(pi*AR*Oswald)); %power loading w/ 1 engine loss

figure(2)
plot(W_SPlane,Psl_W_TOC,W_SPlane,Psl_W_Crit)
hold on
yline((2*engineHP)/MTOW)
hold off
title('Power Loading P/W0 (hp/lb) vs Wing Loading W0/S (lb/ft2) @ Service Ceiling')
legend('Top of Climb','One Engine Loss @ Altitude, 4% CGR','T406 Engine x2')
xlabel('Wing Loading lb/ft2')
ylabel('Power Loading hp/lb')
%% Wing Area Calculation

