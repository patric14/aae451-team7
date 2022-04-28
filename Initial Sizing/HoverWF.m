function W = HoverWF(t, W, Cpower, wt2Power)

W = W * (1 - (Cpower * t) / (wt2Power * 60));

end

