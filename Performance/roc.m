h = 0:100:8000;

ac.W0 = 32964;

for i = 1:length(h)
    [~,~,rho] = AtmosphereFunction(h(i));
    Vbroc(i) = 250; %#ok<*SAGROW> 
    VbrocLast = 0;

    while abs(Vbroc(i) - VbrocLast) >= .1

        ac = liftDrag(ac, ac.W0, Vbroc(i) * 0.592484, h(i));
        VbrocLast = Vbroc(i);
        Vbroc(i) = sqrt(2 / rho * ac.W_S * sqrt(1 / (3 * ac.CD0 * pi * ac.AR * ac.e)));
    end
    thrust = 550 * ac.propellerEff * ac.totalPower / Vbroc(i);
    gamma(i) = thrust / ac.W0 - 1 / ac.L_D;
    Vv(i) = Vbroc(i) * gamma(i);
end

gamma = gamma * 180 / pi;
Vbroc = Vbroc * 0.592484; % Convert V best ROC to kts
Vv = Vv * 60;
plot(h, Vv / 1000)
%axis([-inf inf 0 15])
xlabel('Altitude (ft)')
ylabel('Rate of Climb (ft x 1000 / min)')
yyaxis('right')
plot(h, Vbroc)
ylabel('V_{best ROC} (knots)')
set(gca, 'fontsize', 14)
title('Climb Performance')