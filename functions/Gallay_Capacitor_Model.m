function Nf = Gallay_Capacitor_Model(Irms, duration)
%reference : Metallized Film Capacitor Lifetime Evaluation and Failure Mode
%Analysis R. Gallay Garmanage, Farvagny-le-Petit, Switzerland
%Parameters of capcitor B25655P4507K130 are used here
% Irms is the rms of capacitor current over a whole cycle
t_test = 15000; %in hours, tested at Vtest and T_test
T_test = 105 + 273.15; %test temperature to gain t nominal
Vtest = 675; %test voltage of the capacitor
Vn = 450; %nominal voltage
ESR = 0.001;%mOhm
Rth = 2.08;%estimated
Ea_kb = 7000;
alpha = 3.5;
Tn = 50;
t_nominal = t_test/exp(Ea_kb*(1/T_test - 1/(273.15 + Tn)))/exp(0 - alpha*(Vtest-Vn)/Vn);

T = Tn + ESR .* (Irms.^2) .* Rth + 273.15;
U = 360;

tf = t_nominal.*exp(Ea_kb.*(1./T - 1/(273.15 + 25))).*exp(-alpha*(U - Vn)/Vn);
Nf = tf*3600/duration;
end

