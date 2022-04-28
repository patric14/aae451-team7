function out = fireSizing(ac, fire, time, dist)

W0 = ac.W0_guess;
densityWater = 8.34; %lbs/gal

% Pallet Weight
waterVolume = 231 * fire.galWater;
tankWidth = 92;
tankHt = sqrt(waterVolume / tankWidth);
if tankHt > 60
    tankHt = 60;
end
tankLength = waterVolume / (tankHt * tankWidth);
wPallet = 0.02 * tankWidth * (tankHt + tankLength) + ...
    3.14 * fire.galWater ^ 0.665;

wWater = densityWater * fire.galWater + wPallet;
We = W0 * .7; %wEmpty(W0, ac.AR, P_W, ac.W_S, ac.W_D, ac.Vmax);
wFuel = W0 - We - wWater;

disp('-------------Fire Sizing-------------')
fprintf('\n')

% Run for range of trips
for currentTripNumber = fire.trips
    W0_last = 0;

    % Loop until empty weight converges
    while (abs(W0 - W0_last) > 5)
        weightToPower = (W0) / ac.totalPower;
        We = wEmpty(W0, ac.AR, weightToPower, ac.W_S, ac.W_D, ac.Vmax);
        Wstartup = We + wFuel;
        wTakeoff           = HoverWF(time.takeoff, Wstartup, ac.PSFC, weightToPower);
        wClimb             = .985 * wTakeoff;%CruiseWF(dist.climb, wTakeoff, ac.PSFC, ac.propellerEff, ac.LD);
        wCruiseToWater    = CruiseWF(dist.mainCruz, wClimb, ac.PSFC, ac.propellerEff, ac.LD);
        wBurnBeforeWater = Wstartup - wCruiseToWater;
        tripCounter = 1;

        % Repeated each firefighting trip
        while (tripCounter <= currentTripNumber)
            wDescentToWater    = CruiseWF(dist.waterDescent, wCruiseToWater, ac.PSFC, ac.propellerEff, ac.LD);
            wWaterPickup       = HoverWF(time.waterPickup, wDescentToWater + wWater, ac.PSFC, weightToPower);
            wAscendFromWater   = .985 * wWaterPickup;%CruiseWF(dist.waterClimb, wWaterPickup, ac.PSFC, ac.propellerEff, ac.LD);
            wWaterCruise       = CruiseWF(dist.waterCruz, wAscendFromWater, ac.PSFC, ac.propellerEff, ac.LD);
            wDropDescent       = CruiseWF(dist.waterDescent, wWaterCruise, ac.PSFC, ac.propellerEff, ac.LD);
            wWaterDrop         = CruiseWF(dist.waterDrop, wDropDescent, ac.PSFC, ac.propellerEff, ac.LD);
            wPostDropAscent    = CruiseWF(dist.waterDescent, wWaterDrop - wWater, ac.PSFC, ac.propellerEff, ac.LD);
            wCruiseToWater     = CruiseWF(dist.waterCruz, wPostDropAscent, ac.PSFC, ac.propellerEff, ac.LD);
            tripCounter = tripCounter + 1;
        end

        wReturnToBase      = CruiseWF(dist.mainCruz, wCruiseToWater, ac.PSFC, ac.propellerEff, ac.LD);
        wDescentToLand     = CruiseWF(dist.descent, wReturnToBase, ac.PSFC, ac.propellerEff, ac.LD);
        wLanding           = HoverWF(time.landing, wDescentToLand, ac.PSFC, weightToPower);
        
        
        wFinal = wLanding - .1 * wFuel;
        wDiff = wFinal - We;

        % See how close empty weight is, recalculate fuel weight
        if wDiff > 1 || wDiff < 0
            wFuel = wFuel - wFuel * wDiff / W0;
        end

        W0_last = W0;
        W0 = wWater + We + wFuel - wBurnBeforeWater;
    end

    % Get statistics
    MTOWS(currentTripNumber) = W0; %#ok<*AGROW>
    emptyWeightFractions(currentTripNumber) = We / W0;
    stats = statsCalc(time, dist, fire.galWater, currentTripNumber, ac.Vcruz); %#ok<*SAGROW>
    galPerHr(currentTripNumber) = stats.galPerHr;
    totalDist(currentTripNumber) = stats.totalDist;
    fuelBurn(currentTripNumber) = wFuel;
    fuelBurnHour(currentTripNumber) = wFuel / stats.totalTime;
    fuelWtTrip(currentTripNumber) = wFuel;

    if isfield(fire, 'fuelLimit')
        % Trips possible with fuel limit?
        if wFuel <= fire.fuelLimit
            maxTripsPossible = currentTripNumber;
        end
    end

    % Print Results to screen
    disp(['Num Trips = ' num2str(currentTripNumber)])
    disp(['MTOW = ' num2str(W0) ' lbs.'])
    disp(['Empty weight = ' num2str(We) ' lbs.'])
    disp(['Fuel weight = ' num2str(wFuel) ' lbs.'])
    disp(['Distance Flown = ' ...
        num2str(totalDist(currentTripNumber)) ' nm.'])
    fprintf('\n')
end

if isfield(fire, 'fuelLimit')
    try
        disp(['Number of trips possible = ' num2str(maxTripsPossible)])
    catch
        warning('Zero trips possible with current fuel load!')
    end
    fprintf('\n')
end

% Stuff to plot
for i = 1:6
    toPlot.plotXs{i} = fire.trips;
    toPlot.xlabel{i} = 'Number of trips';
end
toPlot.plotYs = {MTOWS; galPerHr; totalDist; emptyWeightFractions; ...
    fuelBurnHour; galPerHr./fuelBurnHour};
toPlot.ylabel = {'MTOW [lbs]'; 'Gallons of water delivered per hour'; ...
    'Total Distance Flown'; 'Empty Weight Fraction'; ...
    'Fuel burn per hour [lbs]'; 'Gal of Water / Gal of Fuel'};
%toPlot.decidedTrips = fire.decidedTrips;

% Build output structure
out.MTOWS = MTOWS;
out.Wes = emptyWeightFractions .* MTOWS;
out.totalDist = totalDist;
out.fuelBurn = fuelBurn;
out.fuelBurnHour = fuelBurnHour;
out.toPlot = toPlot;
out.wFuel = fuelWtTrip;
out.stats = stats;
end

