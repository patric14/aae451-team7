function out = ramSizing(ac, ram, time, dist, heavyRamOut)

disp('-------------RAM Sizing-------------')
fprintf('\n')

wPax = ram.pax * ram.wtPerPax;
ram.wPax = wPax;
W0 = ram.W0_guess;
We = .7 * W0;

wFuel = W0 - We - wPax;

if ~isfield(ram, 'range')
    ram.range = dist.ramRange;
end

for i = 1:length(ram.range)
    wDiff = 100;
    while wDiff >= 5
        weightToPower = W0 / ac.totalPower;
        We = wEmpty(W0, ac.AR, weightToPower, ac.W_S, ac.W_D, ac.Vmax);
        wTakeoff           = HoverWF(time.takeoff, W0, ac.PSFC, weightToPower);
        wClimb             = .985 * wTakeoff;
        ac                 = liftDrag(ac, wClimb, ac.Vcruz, ac.cruzH);
        ac.cruzL_D         = ac.L_D;
        wCruise            = CruiseWF(ram.range(i), wClimb, ac);
        ac                 = liftDrag(ac, wCruise, 200, 2000);
        wDescentToLand     = CruiseWF(dist.descent, wCruise, ac);
        wLanding           = HoverWF(time.landing, wDescentToLand, ac.PSFC, weightToPower);
        wFinal = wLanding - .10 * wFuel;
        wDiff = wFinal - (We + wPax);

        if wDiff >= 1 || wDiff < 0
            wFuel = wFuel - wFuel * wDiff / We;
        end
        W0 = wPax + We + wFuel;
    end

    % Print results to screen
    disp(['MTOW = ' num2str(W0)])
    disp(['Fuel Weight = ' num2str(wFuel)])
    disp(['Empty weight = ' num2str(We) ' lbs.'])
    disp(['Passenger weight = ' num2str(wPax) ' lbs.'])
    disp(['Empty weight fraction = ' num2str(We / W0)])
    disp(['Range = ', num2str(ram.range(i)) ' nm.'])
    disp(['Cruise L/D = ' num2str(ac.cruzL_D) '.'])
    fprintf('\n')

    % Create output structure
    out.MTOWS(i) = W0;
    out.wFuel(i) = wFuel;
    out.We(i) = We;
    out.emptyWtFrac(i) = We / W0;

end

% Plot stuff
try
    out.plotYs = {out.MTOWS; out.We; out.wFuel ./ heavyRamOut.missionTime};
catch
    warning('Only one point, no out.plotYs generated.')
end

end