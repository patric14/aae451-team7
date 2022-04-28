% Preliminary electric aircraft sizing using range formulation from Martin
% Hepperle, German Aerospace Center, at the Institute of Aerodynamics and
% Flow Technology
R = 240; % nautical miles, set by mission
R = R * 1852; % convert to meters
g = 9.81;
eta = 0.85; % overall efficiency, limited by propeller efficiency (best case)
E = 350; % Wh/kg
L_D = linspace(1,16,2^8); % mission lift-to-drag ratio range, cruise-dominated 
mBat_mTot = (R*g)./(E.*eta.*L_D);
% figure(1)
% subplot(1,2,1)
% plot(L_D,mBat_mTot);
% xlabel('L/D')
% ylabel('m_b_a_t / m_t_o_t')
% title('Battery Mass Fraction for Various Mission L/D (E*=350 Wh/kg)')

%FLIP ANALYSIS, WHAT E DO WE NEED?
E_star = linspace(300,1000,2^8);
L_D_Cruise = 16; % best case scenario for eRAM in cruise (Heart Aero ES-19)
mBat_mTot_E1 = (R*g)./(E_star.*eta.*L_D_Cruise);
mBat_mTot_E2 = (R*g)./(E_star.*eta.*11);
mBat_mTot_E3 = ((120*1852)*g)./(E_star.*eta.*L_D_Cruise);
mBat_mTot_E4 = ((120*1852)*g)./(E_star.*eta.*11);
plot(E_star,mBat_mTot_E2./1000,E_star,mBat_mTot_E1./1000)
hold on
plot(E_star,mBat_mTot_E4./1000,E_star,mBat_mTot_E3./1000)
xline(350,'m')
yline(0.5)
hold off
xlabel('Energy Density [Wh/kg]')
ylabel('m_b_a_t / m_t_o_t')
title('Battery Mass Fraction for Projected Energy Densities')
legend('R=240nm,L/D=11','R=240nm, L/D=16','R=120nm,L/D=11',...
    'R=120nm,L/D=16','2030 Limit','Fuel Mass Fraction Limit')