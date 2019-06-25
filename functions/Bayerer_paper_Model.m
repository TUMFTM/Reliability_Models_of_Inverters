function Nf= Bayerer_paper_Model(Amplitude,Mean,ton,I,V)
    D = 300 * 1e-6;%300 - 500um according to the literature and infineon application note
    %ton and I should be further calculated
    K = 6.1161e+13;
    beta = [-4.416; 1285; -0.463; -0.716; -0.761; -0.5];
    Joints_Num = 24*2*3;%Simplest six-pack module has 24 joints per IGBT, 6 IGBT per module
    Nf = Joints_Num*K*(Amplitude.^beta(1)).*exp(beta(2)./Mean).*ton.^beta(3).*I.^beta(4).*V.^beta(5).*D.^beta(6);
    %reference bayerer paper
end

