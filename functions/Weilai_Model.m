% reference Low Tj Stress Cycle Effect in IGBT Power Module Die-attach Lifetime Modeling
function Nf = Weilai_Model(Amplitude,Mean)
    A1 = 3.71*10^13;
    alpha = -10.122;
    A2 = 9455.52;
    Nf = A1.*(Amplitude.^alpha).*exp(A2./Mean);
end

