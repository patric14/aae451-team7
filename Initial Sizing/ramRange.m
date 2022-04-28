function out = ramRange(ac, ram, time, dist, fireOut)

disp('---------RAM Range Calculation--------')
fprintf('\n')

wPax = ram.pax * ram.wtPerPax;


for i = 1:length(fireOut.Wes)

We = fireOut.Wes(i);
wFuel = fireOut.wFuel(i);
W0 = We + wFuel + wPax;
range = 500;
wDiff = 100;
rangeLast = 0;

while abs(range - rangeLast) >= 5
    weightToPower = W0 / ac.totalPower;
    wTakeoff           = HoverWF(time.takeoff, W0, ac.PSFC, weightToPower);
    wClimb             = CruiseWF(dist.climb, wTakeoff, ac.PSFC, ac.propellerEff, ac.LD);
    wCruise            = CruiseWF(range, wClimb, ac.PSFC, ac.propellerEff, ac.LD);
    wDescentToLand     = CruiseWF(dist.descent, wCruise, ac.PSFC, ac.propellerEff, ac.LD);
    wLanding           = HoverWF(time.landing, wDescentToLand, ac.PSFC, weightToPower);
    wDiff = wLanding - (We + wPax);

    rangeLast = range;
    if wDiff >= 1 || wDiff < 0
        range = range + range * wDiff / We;
    end
end


disp(['MTOW = ' num2str(W0)])
disp(['Fuel Weight = ' num2str(wFuel)])
disp(['Empty weight = ' num2str(We) ' lbs.'])
disp(['Passenger weight = ' num2str(wPax) ' lbs.'])
disp(['Empty weight fraction = ' num2str(We / W0)])
disp(['Range = ', num2str(range) ' nm.'])
fprintf('\n')

out.MTOWS(i) = W0;
out.wFuel(i) = wFuel;
out.We(i) = We;
out.range(i) = range;
out.emptyWtFrac(i) = We/W0;

end

out.missionTime = out.range ./ ac.Vcruz;

% Stuff to plot
for i = 1:3
    toPlot.plotXs{i} = out.range;
    toPlot.xlabel{i} = 'Range [nm]';
end
toPlot.plotYs = {out.MTOWS; out.We; out.wFuel ./ out.missionTime};
toPlot.ylabel = {'MTOW [lbs]'; 'Empty Weight [lbs]'; 'Fuel Burn / Hr [lbs]'};
out.toPlot = toPlot;

end