clear; close all; clc;


enginePower = 6000; %hp
numEngines = 2;
totalPower = enginePower * numEngines;
PSFC = .426; %lb/(hr*hp)
propellerEff = .85;
liftToDrag = 8;
AR = 6;
W_S = 40; %
W_D = 20; % Disk loading lb/ft^2

%---------------------------CHANGE THESE
W0_guess = 39000;
maxTrips = 10;
currentTrip = 1;
MTOWS = zeros(1,20);
Vcruz = 300;
galWater = 1000;
%--------------------------
Vmax = Vcruz * 1.1;
W0 = W0_guess;
W0_last = 0;
densityWater = 8.34; %lbs/gal
wWater = densityWater * galWater;
We = W0 * .7; %wEmpty(W0, AR, P_W, W_S, W_D, Vmax);
wFuel = W0 - We - wWater;
currentTripNumber = 14;

    while W0 ~= W0_last
        W_P = (W0 + wWater) / totalPower; %lb/hp
        WStartup = We + wFuel;
        wTakeoff           = HoverWF(5, WStartup, PSFC, W_P);
        wClimb             = CruiseWF(5, wTakeoff, PSFC, propellerEff, liftToDrag);
        wCruiseToWater    = CruiseWF(100, wClimb, PSFC, propellerEff, liftToDrag);
        We = wEmpty(W0, AR, W_P, W_S, W_D, Vmax);
        tripCounter = 1;
        while (tripCounter <= currentTripNumber)
            wDescentToWater    = CruiseWF(5, wCruiseToWater, PSFC, propellerEff, liftToDrag);
            wWaterPickup       = HoverWF(10, wDescentToWater + wWater, PSFC, W_P);
            wAscendFromWater   = CruiseWF(5, wWaterPickup, PSFC, propellerEff, liftToDrag);
            wWaterCruise       = CruiseWF(20, wAscendFromWater, PSFC, propellerEff, liftToDrag);
            wDropDescent       = CruiseWF(5, wWaterCruise, PSFC, propellerEff, liftToDrag);
            wWaterDrop         = CruiseWF(5, wDropDescent, PSFC, propellerEff, liftToDrag);
            wPostDropAscent    = CruiseWF(5, wWaterDrop - wWater, PSFC, propellerEff, liftToDrag);
            wCruiseToWater     = CruiseWF(20, wPostDropAscent, PSFC, propellerEff, liftToDrag);
            tripCounter = tripCounter + 1;
        end
        wReturnToBase      = CruiseWF(100, wCruiseToWater, PSFC, propellerEff, liftToDrag);
        wDescentToLand     = CruiseWF(5, wReturnToBase, PSFC, propellerEff, liftToDrag);
        wLanding           = HoverWF(5, wDescentToLand, PSFC, W_P);
        wDiff = wLanding - We;

        if wDiff > 100 || wDiff < 0
            wFuel = wFuel - wFuel * wDiff / W0;
        end
        W0_last = W0;
        W0 = wWater + We + wFuel;
    end
disp(['MTOW = ' num2str(W0) ' lbs.'])
disp(['Empty weight = ' num2str(We) ' lbs.'])
disp(['Fuel weight = ' num2str(wFuel) ' lbs.'])


