% Sizing

% Clean your room!
clear; close all; clc;

%% Inputs: Change these parameters to get desired info

mission = 'trade'; % Options: 'fire', 'ram', or 'trade'

% Aircraft Parameters
ac.type = 'vstol';
ac.enginePower = 6000; %hp
ac.numEngines = 2;
ac.totalPower = ac.enginePower * ac.numEngines;
ac.PSFC = .426; %lb/(hr*hp)
ac.propellerEff = .85;
ac.LD = 8;
ac.AR = 6;
ac.W_S = 40; %
ac.W_D = 20; % Disk loading lb/ft^2
ac.W0_guess = 100000;
ac.Vcruz = 300;
ac.Vmax = ac.Vcruz * 1.1;

% RAM parameters
dist.ramRange = 420;
ram.pax = 20;
ram.wtPerPax = 250;
%ram.We = 26996.3521;
ram.W0_guess = 20000;

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

InitialSizing(mission, ac, ram, fire, time, dist)