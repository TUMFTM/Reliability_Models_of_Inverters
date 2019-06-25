function Nf = ENGELMAIER_solder(packagedata,Tam,Top,FF,MEAN)
	% solder fatigue model
    %L length of solder joint
    %h height of solder joint
    %alpha the thermal expansion coefficient difference of substrate and package carrier
    L = packagedata.L;
    h = packagedata.h ;
    alpha = packagedata.alpha;
    doub_epsilon_f = 7;
    delta_gamma = L./sqrt(2)./h.*(alpha.*(Top - Tam))*100;
    f = FF;
    c = -0.442 - (MEAN - 273.15).*6.*1e-4 + 1.74*0.01.*log(1+f);
    Nf = 0.5.*(delta_gamma./doub_epsilon_f).^(1./c);
    %reference ENGELMAIER paper
end
