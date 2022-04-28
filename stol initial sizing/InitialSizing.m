% Sizing

% Clean your room!
clear; close all; clc;

%% Inputs: Change these parameters to get desired info

mission = 'trade'; % Options: 'fire', 'ram', or 'trade'

% Aircraft Parameters
ac.enginePower = 2100; %hp
ac.numEngines = 2;
ac.totalPower = ac.enginePower * ac.numEngines;
ac.PSFC = .485; %lb/(hr*hp)
ac.propellerEff = .9;
ac.LD = 14;
ac.AR = 10;
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
fire.trips = 1:10;
fire.decidedTrips = 4;
fire.fuelLimit = 2800;
fire.galWater = 1000;
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

%% This part actually runs the code
% So don't mess with it unless you're updating

if strcmp(mission, 'fire') || strcmp(mission, 'trade')
    fireOut = fireSizing(ac, fire, time, dist);
    plotter(fireOut.toPlot)
end

if strcmp(mission, 'ram')
    ram.recalcWe = 1;
    liteRamOut = ramSizing(ac, ram, time, dist);
end

if strcmp(mission, 'trade')
    heavyRamOut = ramRange(ac, ram, time, dist, fireOut);
    ram.range = heavyRamOut.range;
    liteRamOut = ramSizing(ac, ram, time, dist);
    toPlot = heavyRamOut.toPlot;
    toPlot.decidedTrips = fire.decidedTrips;
    toPlot.plotYs = [toPlot.plotYs, liteRamOut.plotYs];
    toPlot.subplotLegend = {'RAM and Firefighting', 'RAM only'};
    plotter(toPlot)
    


    clear toPlot;
    toPlot.plotXs = {fire.trips; fire.trips};
    toPlot.xlabel = {'Trips'; 'Trips'};
    pctWtInc = pctDiffCalc(heavyRamOut.We, liteRamOut.We);
    pctFuelInc = pctDiffCalc(heavyRamOut.wFuel, liteRamOut.wFuel);
    toPlot.plotYs = {pctWtInc; pctFuelInc};
    toPlot.ylabel = {'% Difference W_e'; '% Difference fuel burn'};
    toPlot.decidedTrips = fire.decidedTrips;
    plotter(toPlot)
end
    
function pctDiff = pctDiffCalc(new, orig)

pctDiff = (new - orig) ./ orig * 100;

end
