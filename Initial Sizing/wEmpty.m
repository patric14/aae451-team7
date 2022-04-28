function We = wEmpty(W0, AR, W_P, W_S, W_D, Vmax)

We = W0.*(exp(-0.82010).*(W0.^0.043322).*(W_P.^(-0.18598)).*...
    (W_D.^0.074034));

end