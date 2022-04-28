function out = ramRange(ac, ram, time, dist, fireOut)

disp('---------RAM Range Calculation--------')
fprintf('\n')

wPax = ram.pax * ram.wtPerPax;


for i = length(fireOut.Wes)

We = fireOut.Wes(i);
wFuel = fireOut.wFuel(i)% - 807;
W0 = We + wFuel + wPax;
range = 500;
rangeLast = 0;

while abs(range - rangeLast) >= 5
    weightToPower = W0 / ac.totalPower;
    wTakeoff           = HoverWF(time.takeoff, W0, ac.PSFC, weightToPower);
    wClimb             = .985 * wTakeoff;
    ac                 = liftDrag(ac, wClimb, ac.Vcruz + 5, ac.cruzH);
    cruzL_D = ac.L_D;
    cruzCL = ac.CL;
    wCruise            = CruiseWF(range, wClimb, ac);
    ac                 = liftDrag(ac, wCruise, 200, 4000);
    wDescentToLand     = CruiseWF(dist.descent, wCruise, ac);
    ac                 = liftDrag(ac, wDescentToLand, 150, 3000);
    wLoiter            = CruiseWF(75, wDescentToLand, ac);
    wLanding           = HoverWF(time.landing, wLoiter, ac.PSFC, weightToPower);
    wFinal = wLanding;% - .25 * wFuel;
    wDiff = wFinal - (We + wPax);

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
disp(['Cruise L/D = ' num2str(cruzL_D) '.'])
disp(['Cruise CL = ' num2str(cruzCL) '.'])
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