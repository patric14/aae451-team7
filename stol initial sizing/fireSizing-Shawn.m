function fireSizing(ac, fire, time, dist)

decidedTrips = fire.decidedTrips;
W0 = ac.W0_guess;
W0_last = 0;
densityWater = 8.34; %lbs/gal
wWater = densityWater * fire.galWater;
We = W0 * .7; %wEmpty(W0, ac.AR, P_W, ac.W_S, ac.W_D, ac.Vmax);
wFuel = W0 - We - wWater;
maxTrips = 10;
tripNumbers = 1:maxTrips;

for currentTripNumber = fire.trips
    W0_last = 0;
    while (abs(W0 - W0_last) > 10)
        weightToPower = (W0) / ac.totalPower;
        P_W = 1 / weightToPower;
        WStac.ARtup = We + wFuel;
        wTakeoff           = HoverWF(time.takeoff, WStac.ARtup, ac.PSFC, weightToPower);
        wClimb             = CruiseWF(dist.climb, wTakeoff, ac.PSFC, ac.propellerEff, ac.LD);
        wCruiseToWater    = CruiseWF(dist.mainCruz, wClimb, ac.PSFC, ac.propellerEff, ac.LD);
        We = wEmpty(W0, ac.AR, weightToPower, ac.W_S, ac.W_D, ac.Vmax);
        tripCounter = 1;
        %currentTripNumber
        while (tripCounter <= currentTripNumber)
            wDescentToWater    = CruiseWF(dist.waterDescent, wCruiseToWater, ac.PSFC, ac.propellerEff, ac.LD);
            wWaterPickup       = HoverWF(time.waterPickup, wDescentToWater + wWater, ac.PSFC, weightToPower);
            wAscendFromWater   = CruiseWF(dist.waterClimb, wWaterPickup, ac.PSFC, ac.propellerEff, ac.LD);
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
        wDiff = wLanding - We;
    
        

        if wDiff > 10 || wDiff < 0
            wFuel = wFuel - wFuel * wDiff / W0;
        end
        W0_last = W0;
        W0 = wWater + We + wFuel;

       
    end
    disp(['Num Trips = ' num2str(currentTripNumber)])
    disp(['MTOW = ' num2str(W0) ' lbs.'])
    %fprintf('Number of Trips: %d   MTOW: %.3d\n', currentTripNumber, W0);
    MTOWS(currentTripNumber) = W0;
    emptyWeightFractions(currentTripNumber) = We / W0;
    stats = statsCalc(time, dist, fire.galWater, currentTripNumber, ac.Vcruz); %#ok<*SAGROW> 
    galPerHr(currentTripNumber) = stats.galPerHr;
    totalDist(currentTripNumber) = stats.totalDist;
    fuelBurn(currentTripNumber) = wFuel;
    fuelBurnHour(currentTripNumber) = wFuel / stats.totalTime;
    if wFuel <= fire.fuelLimit
        maxTripsPossible = currentTripNumber;
    end

    disp(['Empty weight = ' num2str(We) ' lbs.'])
    disp(['Fuel weight = ' num2str(wFuel) ' lbs.'])
    fprintf('\n')
end
 
disp(['Number of trips possible = ' num2str(maxTrips)])

% MTOW trade
% figure
% plot(MTOWS)
% xlabel('# Trips')
% ylabel('MTOW [lbs]')
% 
% % gal/hr trade
% figure
% plot(galPerHr)
% xlabel('# Trips')
% ylabel('Gallons of water delivered per hour')
% 
% figure
% plot(totalDist)
% xlabel('# Trips')
% ylabel('Total Distance Flown')
% 
% figure
% plot(fuelBurn)
% xlabel('# Trips')
% ylabel('Fuel burn per trip [lbs]')
% 
% figure;
% plot(fuelBurnHour)
% xlabel('# Trips')
% ylabel('Fuel burn per hour [lbs]')
% subplot(2,3,1);
% % MTOW trade
% plot(MTOWS, 'LineWidth',2);
% xlabel('# Trips')
% ylabel('MTOW [lbs]')
% grid on;
% 
% % gal/hr trade
% subplot(2,3,2);
% plot(galPerHr, 'LineWidth',2);
% xlabel('# Trips')
% ylabel('Gallons of water delivered per hour')
% grid on;
% 
% subplot(2,3,3);
% plot(totalDist, 'LineWidth',2);
% xlabel('# Trips')
% ylabel('Total Distance Flown')
% grid on;
% 
% subplot(2,3,4);
% plot(fuelBurn, 'LineWidth', 2);
% xlabel('# Trips')
% ylabel('Fuel burn [lbs]')
% grid on;
% 
% subplot(2,3,5);
% plot(fuelBurnHour, 'LineWidth',2);
% xlabel('# Trips')
% ylabel('Fuel burn per hour [lbs]')
% grid on;
% 
% subplot(2,3,6);
% plot(fuelBurnHour./galPerHr, 'LineWidth',2);
% xlabel('# Trips')
% ylabel('Gal of Water Dropped per Gal of Fuel Burned ')
% grid on;

subplot(2,3,1);
% MTOW trade
plot(MTOWS, 'LineWidth',2); hold on;
plot(decidedTrips, MTOWS(decidedTrips),'r.', 'MarkerSize',20);
xline(decidedTrips,'r--'); yline(MTOWS(decidedTrips),'r--');
xlabel('# Trips')
ylabel('MTOW [lbs]')
grid on;
% gal/hr trade

subplot(2,3,2);
plot(galPerHr, 'LineWidth',2);hold on;
plot(decidedTrips, galPerHr(decidedTrips),'r.', 'MarkerSize',20);
xline(decidedTrips,'r--'); yline(galPerHr(decidedTrips),'r--');
xlabel('# Trips')
ylabel('Gallons of water delivered per hour')
grid on;

subplot(2,3,3);
plot(totalDist, 'LineWidth',2);hold on;
plot(decidedTrips, totalDist(decidedTrips),'r.', 'MarkerSize',20);
xline(decidedTrips,'r--'); yline(totalDist(decidedTrips),'r--');
xlabel('# Trips')
ylabel('Total Distance Flown')
grid on;
subplot(2,3,4);
plot(emptyWeightFractions, 'LineWidth', 2);hold on;
plot(decidedTrips, emptyWeightFractions(decidedTrips),'r.', 'MarkerSize',20);
xline(decidedTrips,'r--'); yline(emptyWeightFractions(decidedTrips),'r--');
xlabel('# Trips')
ylabel('Empty Weight Fraction');
grid on;
subplot(2,3,5);
plot(fuelBurnHour, 'LineWidth',2);hold on;
plot(decidedTrips, fuelBurnHour(decidedTrips),'r.', 'MarkerSize',20);
xline(decidedTrips,'r--'); yline(fuelBurnHour(decidedTrips),'r--');
xlabel('# Trips')
ylabel('Fuel burn per hour [lbs]')
grid on;
subplot(2,3,6);
plot(galPerHr./fuelBurnHour, 'LineWidth',2);hold on;
plot(decidedTrips, galPerHr(decidedTrips)./(fuelBurnHour(decidedTrips)),'r.', 'MarkerSize',20);
xline(decidedTrips,'r--'); yline(galPerHr(decidedTrips)./(fuelBurnHour(decidedTrips)),'r--');
xlabel('# Trips')
ylabel('Gal of Water / Gal of Fuel')
grid on;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [.25 .25 .75 .75]);

end

