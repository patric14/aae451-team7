function ac = InitialSizing(mission, ac, ram, fire, time, dist)

%% This part actually runs the code
% So don't mess with it unless you're updating

if strcmp(mission, 'fire') || strcmp(mission, 'trade')
    [fireOut, ac] = fireSizing(ac, fire, time, dist);
    try
    plotter(fireOut.toPlot)
    end
end

if strcmp(mission, 'ram')
    ram.recalcWe = 1;
    liteRamOut = ramSizing(ac, ram, time, dist);
end

if strcmp(mission, 'trade')
    heavyRamOut = ramRange(ac, ram, time, dist, fireOut);
    ram.range = heavyRamOut.range;
    liteRamOut = ramSizing(ac, ram, time, dist, heavyRamOut);
    toPlot = heavyRamOut.toPlot;
    toPlot.decidedTrips = fire.decidedTrips;
    toPlot.plotYs = [toPlot.plotYs, liteRamOut.plotYs];
    toPlot.subplotLegend = {'RAM and Firefighting', 'RAM only'};
    plotter(toPlot)
    


    clear toPlot;
    toPlot.plotXs = {fire.trips; fire.trips};
    toPlot.xlabel = {'Trips'; 'Trips'};
    pctWtInc = pctDiffCalc(heavyRamOut.We, liteRamOut.We);
    pctFuelInc = pctDiffCalc(heavyRamOut.wFuel / fireOut.stats.totalTime, liteRamOut.wFuel / fireOut.stats.totalTime);
    toPlot.plotYs = {pctWtInc; pctFuelInc};
    toPlot.ylabel = {'% Difference W_e'; '% Difference fuel burn'};
    toPlot.decidedTrips = fire.decidedTrips;
    plotter(toPlot)
end

if strcmp(mission, 'final')
    [fireOut, ac] = fireSizing(ac, fire, time, dist);
    ramRange(ac, ram, time, dist, fireOut);
end

function pctDiff = pctDiffCalc(new, orig)

pctDiff = (new - orig) ./ orig * 100;

end

end
