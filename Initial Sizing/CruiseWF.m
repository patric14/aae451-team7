function W = CruiseWF(R, W, Cpower, etaP, L_D)

W = W * exp(-R * Cpower / (325.9 * etaP * L_D));

end

