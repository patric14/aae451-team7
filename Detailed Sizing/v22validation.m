% Sizing

% Clean your room!
clear; close all; clc;

%% Inputs: Change these parameters to get desired info

mission = 'ram'; % Options: 'fire', 'ram', or 'trade'

% Aircraft Parameters
ac.enginePower = 6150; %hp
ac.numEngines = 2;
ac.totalPower = ac.enginePower * ac.numEngines;
ac.PSFC = .426; %lb/(hr*hp)
ac.propellerEff = .6;
ac.LD = 4;
ac.AR = 6.97;
S = 301;
W0 = 47500;
ac.W_S = W0 / S; %
ac.W_D = W0 / (2267.9559 * 2); % Disk loading lb/ft^2
ac.W0_guess = 100000;
ac.Vcruz = 250;
ac.Vmax = ac.Vcruz * 1.1;

% Aircraft geometry
ac.dragbodies = {'fuse', 'nacelle', 'wing', 'horiz_tail', 'vert_tail'};
wing.sw = S;
wing.sweep = 0;
wing.t_c = .15;
ac.wing = wing;
fuse.l = 57.33333;
fuse.D = 7.92;
fuse.xSection = 'rect';
ac.fuse = fuse;
nacelle.l = 18;
nacelle.D = 5;
ac.nacelle = nacelle;
horiz_tail.config = 'H';
horiz_tail.sw = 118.11024;
horiz_tail.AR = 2;
horiz_tail.t_c = .10;
ac.horiz_tail = horiz_tail;
vert_tail.config = 'H';
vert_tail.sw = horiz_tail.sw * .8 * 2;
vert_tail.AR = 1.5;
vert_tail.t_c = .10;
ac.vert_tail = vert_tail;

% Performance

% RAM parameters
dist.ramRange = 879.0497;
ram.pax = 26;
ram.wtPerPax = 250;
%ram.We = 26996.3521;
ram.W0_guess = W0;
ac.cruzH = 25000;

% Fire Parameters
fire.trips = 1:20;
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


