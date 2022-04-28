% AAE 451 - Group 7
% Tiltrotor empty weight sizing
% The following code uses a database of gross weight, power loading
% and disk loading for regional-air-mobility-sized tiltrotors and sizes
% their empty weight ratio 1) according to gross weight and 2) using all
% three measures.

% Database Values in this order: Bell XV-15, Uni of Maryland Excalibur,
% AugustaWestland AW609, Bell V-247, Bell V-280, Boeing MV22, NASA
% Conventional Tiltrotor Baseline, NASA Variable Diameter Tiltrotor
% (ascending gross weight)

% All calculations performed in English units

We_W0 = [0.7362,0.6293,0.6253,0.5517,0.5857,0.8055,0.7040,0.7199];
W0 = [13000,16145,16799,29000,30865,39500,48334,48883]; % lb
W0_P = [2.2222,2.6908,6.5982,4.8333,4.4093,3.8610,2.3585,3.0581]; %lb/hp
W0_S = [15.2,11,15.9,20.5133,16,20.9,18,11]; %lb/ft^2

W0_Cont = 13000:49000; %Continous W0 for models
W0_P_Cont = linspace(4,5,36001); % Raymer's Tiltrotor Power Loading Range (Table 20.1)
W0_S_Cont = linspace(15,25,36001); % Raymer's Tiltrotor Disk Loading Range (Table 20.2)

emptyWeightPowerFit = 0.3739.*(W0_Cont.^0.0564); % obtained in Excel analysis
% Linearize the relationship We/W0 = A*(W0^c1)*(W0_P^c2)*(W0_S^c3)
x1 = log(W0);
x2 = log(W0_P);
x3 = log(W0_S);
y = log(We_W0);
% Solve the linear regression
n = length(x1);
a = [ones(n,1) x1' x2' x3'];
c = pinv(a)*y';
% Re-write the expression after e taken to power of each side
emptyWeightRegression = (exp(c(1))).*(W0_Cont.^c(2)).*(W0_P_Cont.^c(3)).*...
    (W0_S_Cont.^c(4));

% R-Squared Tool in MATLAB
powerMDL = fitlm(x1', y')
lrMDL = fitlm([x1' x2' x3'], y')
emptyWeightRegression2 = (exp(-0.8201)).*(W0_Cont.^0.04332).*...
    (W0_P_Cont.^(-0.1860)).*(W0_S_Cont.^0.07403); %using fitlm

% Plot fits
plot(W0,We_W0,'*')
hold on
plot(W0_Cont,emptyWeightPowerFit,'--',W0_Cont,emptyWeightRegression,'--',...
    'LineWidth',2)
plot(W0_Cont,emptyWeightRegression2)
hold off
legend('Catalogue Data','Excel Power Fit','MATLAB Regression Fit',...
    'Improved MATLAB Regression Fit')
xlabel('Gross Weight (lb)')
ylabel('Empty Weight Fraction')

% RMS Analysis
emptyWeightExcel = [emptyWeightPowerFit(W0==13000) emptyWeightPowerFit(W0==16145) ...
    emptyWeightPowerFit(W0==16799) emptyWeightPowerFit(W0==29000) ...
    emptyWeightPowerFit(W0==30865) emptyWeightPowerFit(W0==39500) ...
    emptyWeightPowerFit(W0==48334) emptyWeightPowerFit(W0==48883)];

RMSE_Excel = sqrt(mean((We_W0 - emptyWeightExcel).^2));

emptyWeightMATLAB = [emptyWeightRegression(W0==13000) emptyWeightRegression(W0==16145) ...
    emptyWeightRegression(W0==16799) emptyWeightRegression(W0==29000) ...
    emptyWeightRegression(W0==30865) emptyWeightRegression(W0==39500) ...
    emptyWeightRegression(W0==48334) emptyWeightRegression(W0==48883)];

RMSE_MATLAB = sqrt(mean((We_W0 - emptyWeightMATLAB).^2));






