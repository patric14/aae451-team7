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
    W0last = 0;
    while wDiff >= 5
        weightToPower = W0 / ac.totalPower;
        We = wEmpty(W0, ac.AR, weightToPower, ac.W_S, ac.W_D, ac.Vmax);
        wTakeoff           = HoverWF(time.takeoff, W0, ac.PSFC, weightToPower);
        wClimb             = CruiseWF(dist.climb, wTakeoff, ac.PSFC, ac.propellerEff, ac.LD);
        wCruise            = CruiseWF(ram.range(i), wClimb, ac.PSFC, ac.propellerEff, ac.LD);
        wDescentToLand     = CruiseWF(dist.descent, wCruise, ac.PSFC, ac.propellerEff, ac.LD);
        wLanding           = HoverWF(time.landing, wDescentToLand, ac.PSFC, weightToPower);
        wDiff = wLanding - (We + wPax);

        if wDiff >= 1 || wDiff < 0
            wFuel = wFuel - wFuel * wDiff / We;
        end

        W0last = W0;
        W0 = wPax + We + wFuel;
    end

    % Print results to screen
    disp(['MTOW = ' num2str(W0)])
    disp(['Fuel Weight = ' num2str(wFuel)])
    disp(['Empty weight = ' num2str(We) ' lbs.'])
    disp(['Passenger weight = ' num2str(wPax) ' lbs.'])
    disp(['Empty weight fraction = ' num2str(We / W0)])
    disp(['Range = ', num2str(ram.range(i)) ' nm.'])
    fprintf('\n')

    % Create output structure
    out.MTOWS(i) = W0;
    out.wFuel(i) = wFuel;
    out.We(i) = We;
    out.emptyWtFrac(i) = We / W0;

end

% Plot stuff
out.plotYs = {out.MTOWS; out.We; out.wFuel ./ heavyRamOut.missionTime};

end