function W = climbWF(R, W, ac, V, h)

[~, ~, L_D] = liftDrag(ac, W * 1.5, V, h);
W = W * exp(-R * ac.PSFC / (325.9 * ac.propellerEff * L_D));

end

