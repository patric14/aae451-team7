% Sizing

% Clean your room!
clear; close all; clc;

%% Inputs: Change these parameters to get desired info

ac.mission = 'ram'; % Options: 'fire', 'ram', or 'trade'

%% Aircraft Parameters

% Engine Stuff
engine.enginePower = 6000; %hp
engine.numEngines = 2;
engine.totalPower = engine.enginePower * engine.numEngines;
engine.PSFC = .426; %lb/(hr*hp)
engine.propEff = .85;

% Aero Stuff
aero.LD = 8;
aero.AR = 6;
aero.dragbodies = {'fuselage', 'wing', 'vertTail', 'hTail', 'nacelles'};

% Perf
perf.Vcruz = 300;
perf.Vmax = perf.Vcruz * 1.1;

% Geometry/Drag buildup
wing.Sw = 301.4; % Taken from V-22, should probs change
fuselage.

% Weights
wt.W_S = 40; %
wt.W_D = 20; % Disk loading lb/ft^2
wt.mtow_guess = 39000;



%% RAM parameters
dist.ramRange = 420;
ram.pax = 20;
ram.wtPerPax = 200;
ram.We = 26996.3521;
ram.W0_guess = 20000;

%% Fire Parameters
fire.trips = 1;
fire.decidedTrips = 9;
fire.fuelLimit = 2800;
fire.galWater = 1000;
time.waterPickup = 1;
dist.mainCruz = 100;
dist.waterDescent = 5;
dist.waterClimb = 5;
dist.waterCruz = 20;
dist.waterDrop = 5;

%% Times
time.takeoff = 5;
time.landing = 5;

%% Distances
dist.climb = 10;
dist.descent = 10;

% Make aircraft 
ac.engine = engine;
ac.aero = aero;
ac.wt = wt;
ac.perf = perf;
ac.dist = dist;
ac.time = time;
ac.ram = ram;
ac.fire = fire;

%% This part actually runs the code
% So don't mess with it unless you're updating

if strcmp(ac.mission, 'fire') || strcmp(ac.mission, 'trade')
    fireOut = fireSizing(ac);
    plotter(fireOut.toPlot)
end

if strcmp(ac.mission, 'ram')
    ram.recalcWe = 1;
    liteRamOut = ramSizing(ac);
end

if strcmp(ac.mission, 'trade')
    heavyRamOut = ramRange(ac, fireOut);
    ac.ram.range = heavyRamOut.range;
    liteRamOut = ramSizing(ac);
    try
        toPlot = heavyRamOut.toPlot;
        toPlot.decidedTrips = fire.decidedTrips;
        toPlot.plotYs = [toPlot.plotYs, liteRamOut.plotYs];
        toPlot.subplotLegend = {'RAM and Firefighting', 'RAM only'};
        plotter(toPlot)
    catch
        warning('Not enough points to plot.')
    end
end
    
