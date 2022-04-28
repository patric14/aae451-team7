% Sizing

% Clean your room!
clear; close all; clc;

%% Inputs: Change these parameters to get desired info

mission = 'final'; % Options: 'fire', 'ram', or 'trade'

% Aircraft Parameters
ac.enginePower = 5000; %hp
ac.numEngines = 2;
ac.totalPower = ac.enginePower * ac.numEngines;
ac.PSFC = .426; %lb/(hr*hp)
ac.propellerEff = .85;
ac.L_D = 13;
ac.AR = 6.178;
S = 350;
W0 = 20000;
ac.W_S = W0 / S; %
ac.W_D = 22;%W0 / (pi * 14 ^ 2 * 2); % Disk loading lb/ft^2
ac.W0_guess = W0;
ac.Vcruz = 280;
ac.VfireCruz = 260;
ac.Vmax = ac.Vcruz * 1.1;
ac.cruzH = 6000;

% Aircraft geometry
ac.dragbodies = {'fuse', 'nacelle', 'wing', 'horiz_tail', 'vert_tail'};
wing.sw = S;
wing.sweep = 0;
wing.t_c = .21;
ac.wing = wing;
fuse.l = 45.12;
fuse.D = 7.52;
fuse.xSection = 'rect';
ac.fuse = fuse;
nacelle.l = 12.5;
nacelle.D = 5.5;
ac.nacelle = nacelle;
horiz_tail.config = 'T';
horiz_tail.sw = 105;
horiz_tail.AR = 3;
horiz_tail.t_c = .12;
ac.horiz_tail = horiz_tail;
vert_tail.config = 'T';
vert_tail.sw = 60;
vert_tail.AR = 1.2;
vert_tail.t_c = .12;
ac.vert_tail = vert_tail;

% Performance

% RAM parameters
dist.ramRange = 879.0497;
ram.pax = 20;
ram.wtPerPax = 250;
%ram.We = 26996.3521;
ram.W0_guess = W0;

% Fire Parameters
fire.trips = 4;
fire.decidedTrips = 4;
fire.fuelLimit = 2800;
fire.galWater = 600;
time.waterPickup = 1;
dist.mainCruz = 100;
dist.waterDescent = 5;
dist.waterClimb = 5;
dist.waterCruz = 20;
dist.waterDrop = 5;

% Times
time.takeoff = 5;
time.landing = 5;

% Distances
dist.climb = 10;
dist.descent = 10;

ac = InitialSizing(mission, ac, ram, fire, time, dist);


