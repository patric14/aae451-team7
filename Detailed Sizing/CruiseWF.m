function W = CruiseWF(R, W, ac)

W = W * exp(-R * ac.PSFC / (325.9 * ac.propellerEff * ac.L_D));

end

