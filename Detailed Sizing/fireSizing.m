function [out, ac] = fireSizing(ac, fire, time, dist)

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
        weightToPower = (W0) / ac.totalPower
        ac.W_S = W0 / ac.wing.sw; %
        ac.W_D = W0 / (pi * 14 ^ 2 * 2); % Disk loading lb/ft^2
        %We = 24953.6587;
        We = wEmpty(W0, ac.AR, weightToPower, ac.W_S, ac.W_D, ac.Vmax);
        Wstartup = We + wFuel;
        wTakeoff           = HoverWF(time.takeoff, Wstartup, ac.PSFC, weightToPower);
        wClimb             = .985 * wTakeoff;
        ac                 = liftDrag(ac, wClimb, ac.VfireCruz, ac.cruzH);
        wCruiseToWater    = CruiseWF(dist.mainCruz, wClimb, ac);
        ac                 = liftDrag(ac, wCruiseToWater, 200, 5000);
        wDescentToWater    = CruiseWF(dist.waterDescent, wCruiseToWater, ac);
        wBurnBeforeWater = Wstartup - wDescentToWater;
        wTrip(1) = wDescentToWater;
        tripCounter = 1;

        % Repeated each firefighting trip
        while (tripCounter <= currentTripNumber)
            
            wWaterPickup       = HoverWF(time.waterPickup, wDescentToWater + wWater, ac.PSFC, weightToPower);
            ac                 = liftDrag(ac, wWaterPickup, ac.Vcruz, 2000);
            wAscendFromWater = wWaterPickup;%   = CruiseWF(dist.waterDescent, wWaterPickup, ac);
            ac                 = liftDrag(ac, wAscendFromWater, ac.Vcruz, 4000);
            
            if tripCounter == 1
                cruzL_D = ac.L_D;
                cruzCL = ac.CL;
            end

            wWaterCruise       = CruiseWF(dist.waterCruz, wAscendFromWater, ac);
            %ac                 = liftDrag(ac, wWaterCruise, 200, 2000);
            wDropDescent       = wWaterCruise; % CruiseWF(dist.waterDescent, wWaterCruise, ac);
            ac                 = liftDrag(ac, wDropDescent, 150, 500);
            wWaterDrop         = CruiseWF(dist.waterDrop, wDropDescent, ac);
            wPostWaterDrop     = wWaterDrop - wWater;
            %ac                 = liftDrag(ac, wPostWaterDrop, 200, 2000);
            wPostDropAscent    = wPostWaterDrop; % CruiseWF(dist.waterDescent, wPostWaterDrop, ac);
            ac                 = liftDrag(ac, wPostDropAscent, ac.Vcruz, 4000);
            wDescentToWater     = CruiseWF(dist.waterCruz, wPostDropAscent, ac);
            
            tripCounter = tripCounter + 1;
            wTrip(tripCounter) = wDescentToWater;
        end
        
        wAscendFromWater   = .985 * wDescentToWater;
        ac                 = liftDrag(ac, wAscendFromWater, ac.VfireCruz, ac.cruzH);
        wReturnToBase      = CruiseWF(dist.mainCruz, wAscendFromWater, ac);
        ac                 = liftDrag(ac, wReturnToBase, 200, 4000);
        wDescentToLand     = CruiseWF(dist.descent, wReturnToBase, ac);
        ac                 = liftDrag(ac, wDescentToLand, 120, 4000);
        wLoiter            = CruiseWF(60, wDescentToLand, ac);
        wLanding           = HoverWF(time.landing, wLoiter, ac.PSFC, weightToPower);
        wFinal = wLanding - .125 * wFuel;
        wDiff = wFinal - We;

        % See how close empty weight is, recalculate fuel weight
        if wDiff > 1 || wDiff < 0
            wFuel = wFuel - wFuel * wDiff / W0;
        end

        W0_last = W0;
        W0 = wWater + We + wFuel - wBurnBeforeWater;
    end

    wLoiter - wLanding ;%+ .125 * wFuel
    % Get statistics
    MTOWS(currentTripNumber) = W0; %#ok<*AGROW>
    emptyWeightFractions(currentTripNumber) = We / W0;
    stats = statsCalc(time, dist, fire.galWater, currentTripNumber, ac); %#ok<*SAGROW>
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
    disp(['Cruise L/D = ' num2str(cruzL_D) '.'])
    disp(['Cruise CL = ' num2str(cruzCL) '.'])
    disp(['Water weight = ' num2str(wWater) ' lbs.'])
    
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
toPlot.decidedTrips = fire.decidedTrips;

% Build output structure
out.MTOWS = MTOWS;
out.Wes = emptyWeightFractions .* MTOWS;
out.totalDist = totalDist;
out.fuelBurn = fuelBurn;
out.fuelBurnHour = fuelBurnHour;
out.toPlot = toPlot;
out.wFuel = fuelWtTrip;
out.stats = stats;

for i = 1:fire.trips + 1
    disp(['Leg ' num2str(i - 1) ' weight = ' num2str(wTrip(i)) ' lbs.'])
end
disp(['Mission Time = ' num2str(stats.totalTime) ' min.'])
fprintf('\n')
end

