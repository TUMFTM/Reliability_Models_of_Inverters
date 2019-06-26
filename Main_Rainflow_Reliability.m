%run this file to directly obtain results

%initialization
clc;
clear;
addpath('data')
addpath('functions')

% define the driving cycle and the inverter type to evaluate
Driving_Cycle_Name = 'WLTP'; % can be 'WLTP', 'FTP72', 'USA_NECC', 'EUROPE_CITY', 'USA_CITY_II', 'ARTEMIS_150' or 'ARTEMIS_130' or 'NEDC' or 'Max_Swing'
Inverter_Type = 'IGBT'; % can be 'CHB' or 'IGBT'


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%calculation starts%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Temperature_Curve_Data = strcat('Temperature_',Driving_Cycle_Name,'_',Inverter_Type,'.mat');
load(Temperature_Curve_Data)
Tj = Tj(:,2);% read temperature curve in 1s time resolution

if strcmp(Inverter_Type,'CHB')
    
    % Parameters
    % Thermal resistance between junction and PCB are ajusted according to the chaging
    % speed of temperatures, the higher the changing speed, the higher the
    % thermal resistance, because it takes time for the PCB to heat up.
    %
    % The other resistance, between junction and heatsink to calculate the
    % temperature of junctions, is not adjusted, as it is only determined
    % by the switch.
    if strcmp(Driving_Cycle_Name,'Max_Swing')
        Rth_PCB_Junction = 9;
        %because not enough time to heatup the PCBs, thermal resistance form junction to PCB solder joints
    else
        Rth_PCB_Junction = 1.5;
        %in normal simulations, it is set to be 1.5
        %in fact, these thermal resistance factors are all pessimistic, realistically, if well
        %isolated, which is commonly the case, these factors can be 10-20,
        %and the reliability of the CHB can be significantly improved.
        %If necessary, a sensitivity analysis can be conducted.
    end
    board_temp_series = (Tj - 30)/Rth_PCB_Junction + 30 + 273.15;
    %take the case temperature as the board temp
    %this assumption makes sense because SMD MOSFET usually are put on, alu-base PCB and the temperature of PCB is quite uniform
    board_param.D   = 18900*1e6*0.0016^3/12/(1-0.3^2);%Ref: Vibration Analysis of a Simply Supported PCB with a Component- An Analytical Approach
    board_param.rou = 1.850 * 10^3;
    %FR-4 material, most common for PCB
    board_param.a   = 0.306;
    %according to the self-designed PCB as a worst case
    board_param.b   = 0.254;
    %according to the self-designed PCB as a worst case
    board_param.point_number = 500;
    % according to the self-designed PCB as a worst case
    board_param.board_number = 9;
    board_param.amplitude    = 0.9; % maximum vibration, m/s^2, reference: Classification of the road surface condition on the basis of vibrations of the sprung mass in a passenger car;
    duration = length(Tj);
    
    
    %1 switch junction reliability with Aalborg Model
    switch_num  = 4*6*3*3;
    junction_num = 4*6*3*3;
    Tj          = (Tj - 30) + 30;
    [c,hist,edges,rmm,idx] = rainflow(Tj+273.15,1);%rainflow counting
    Count       = c(:,1);% number of stress cycles
    Amplitude   = c(:,2);%amplitude of stress cycles 
    Mean        = c(:,3); % average value, change ambient temp to 50C
    Nfswitch    = Weilai_Model(Amplitude,Mean);%that model is dedicatedly designed for MOSFET
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %2 bond wire reliability
    bonds_per_switch = 4; 
    parallel = 6;
    joints_per_switch = 5;
    curvename = strcat('UICurve_',Driving_Cycle_Name,'_',Inverter_Type,'.mat');
    load(curvename);
        
    a       = size(c);
    % a is used here as an index to fit the IGBT model, the 0.5 cycles are excluded fron this model
    a(1)    = a(1);
    %find the lase non 0.5 index
    ton_MOSFET = zeros(a(1),1);
    %intilize a vector to save on-time
    I_MOSFET  = zeros(a(1),1);
    %intilize a vector to save currents
    toncurve  = (uicos(:,2)./sqrt(3/2)./pi.*2)/180;
    %calculate average on time of MOSFET
    Icurve    = uicos(:,2)./sqrt(3);
    % calculate the Irms of the second

    for i = 1:a(1)
%         if(c(i,1) < 1)
%             continue;
%         end
        ton_MOSFET(i) = sum(toncurve(c(i,4)+1:c(i,5)+1));
        I_MOSFET(i)   = sqrt(sum(Icurve(c(i,4)+1:c(i,5)+1).^2)/(c(i,5)-c(i,4)+1))./parallel./bonds_per_switch;
    end
    %calculate the values in each temperature stress curve
    V = 100;
    NfBond   = Bayerer_paper_Model(Amplitude(1:a(1)),Mean(1:a(1)),ton_MOSFET,I_MOSFET,V);
    %Bayerer model for reliability of bond wires
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %3 capacitor reliability
    Damage_capacitor = 0;% No DC link capacitor in CHB
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
else% the inverter type is IGBT
 

    %board solder reliability parameters
    Rth_PCB_Junction = 30; 
    % IGBTs are packaged in a module. Most heat goes via the metalic
    % cooling pad. Additionally, as the ceramic casing is rather thermally
    % isolated, only a small portion of heat is leaked through the ceramic package
    % shell to the board, therefore, the board temp is rather decoupled from
    % Tj compared to MOSFET. The Rth is assumed to be 30, to create the
    % best case for the IGBT inverter.
    board_temp_series = (Tj - 50)/Rth_PCB_Junction  + 30 + 273.15;
    board_param.D   = 18900*1e6*0.0016^3/12/(1-0.3^2);
    % Ref: Vibration Analysis of a Simply Supported PCB with a Component- An Analytical Approach
    board_param.rou = 1.850 * 10^3;
    % FR-4 material, most common for PCB
    board_param.a   = 0.213*2;
    % estimated based on ORNL and IGBT module deatasheet, roughly PCB is two times large in both dimensions
    board_param.b   = 0.97*2;
    % estimated based on ORNL and IGBT module deatasheet, roughly PCB is two times large in both dimensions
    board_param.point_number = 24;
    % according to the datasheet of FS800R07A2E3 module, only 24 soldering pins
    board_param.board_number = 1;
    board_param.amplitude    = 0.9;
    % maximum vibration, m/s^2;
    
    curvename = strcat('UICurve_',Driving_Cycle_Name,'_',Inverter_Type,'.mat');
    load(curvename);
  
    % capacitor reliability
    % calculate the rms ripple of the DC link capacitor
    % Ref: Analysis and Minimization of Ripple Components of Input Current and Voltage of PWM Inverter
    toncurve  = (uicos(:,2)./sqrt(3/2)./pi.*2)/180;
    % calculate average on time of IGBT
    Icurve    = uicos(:,2)./sqrt(3);
    % calculate the Irms of the second
    m_index   = uicos(:,2)./sqrt(3/2)./180;
    % modulation index
    costheta  = uicos(:,4);
   
    %1 switch junction reliability with Aalborg Model
    switch_num  = 3;
    junction_num = 25;
    if(~strcmp(Driving_Cycle_Name,'Max_Swing'))
        Tj          = (Tj - 50) + 30;
        % 0.14(rthj-c-s) instead of 0.23 used in the simulation, it is a correction factor;
        % Change ambient from 50 to 30, also a correction factor for the
        % ambient temperature
    end
    [c,hist,edges,rmm,idx] = rainflow(Tj+273.15,1);%rainflow counting
    Count       = c(:,1);
    % Number of stress cycles
    Amplitude   = c(:,2);
    % Amplitude of stress cycles 
    Mean        = c(:,3);
    Nfswitch    = Weilai_Model(Amplitude,Mean);
    % That model is dedicatedly designed for MOSFET
   
    %2 Bond reliability
    parallel = 4;
    bonds_per_switch = 8; 
    joints_per_switch = 24;
    % Obtain IGBT on time and Irms
    a       = size(c);
    % A is used here as an index to fit the IGBT model, the 0.5 cycles are excluded fron this model
    a       = a(1);
    % Find the lase non 0.5 index
    ton_IGBT = zeros(a(1),1);
    % Intilize a vector to save on-time
    I_IGBT  = zeros(a(1),1);
    % Intilize a vector to save currents
    for i = 1:a(1)
        ton_IGBT(i) = sum(toncurve(c(i,4)+1:c(i,5)+1));
        I_IGBT(i)   = sqrt(sum(Icurve(c(i,4)+1:c(i,5)+1).^2)/(c(i,5)-c(i,4)+1))./parallel./bonds_per_switch;
    end
    % Calculate the values in each temperature stress curve
    V = 360;
    NfBond = Bayerer_paper_Model(Amplitude(1:a(1)),Mean(1:a(1)),ton_IGBT,I_IGBT,V)./c(:,1);
    
    %3 Capacitor reliability
    Iripple_rms = Icurve.*sqrt(m_index.*(sqrt(3)/2 + (2*sqrt(3)/pi - m_index.*9/8).*costheta.^2));
    % the ripple rms current of the capacitor, formulated obtained in the
    % ref mentioned above
    duration = length(Iripple_rms);
    Ic_rms   = sqrt(sum(Iripple_rms.^2)./duration);
    % real RMS value over the whole driving cycle
    Damage_capacitor = 1/Gallay_Capacitor_Model(Ic_rms, duration);
end

%%
Damage_switch           = sum(Count./Nfswitch)*junction_num; 
Damage_bond             = sum(1./NfBond)*junction_num*joints_per_switch;
Damage_solder_board     = 1./Board_Reliability(board_param, duration, board_temp_series);
Pie = [Damage_switch; Damage_bond; Damage_solder_board;Damage_capacitor];
Pie = Pie./sum(Pie);
%PCB solder reliability model is explained in the function

switch Driving_Cycle_Name
    % here all the constant values (12.07 etc.) refer to the range of the corresponding driving cycle
    % as the initial result is the cycle life, multiplying cycle life with the driving cycle range 
    % will result in a mileage life
    case 'FTP72'
        Range_to_Death = 12.07/(Damage_switch + Damage_bond + Damage_solder_board + Damage_capacitor);
    case 'NEDC'
        Range_to_Death = 11.023/(Damage_switch + Damage_bond + Damage_solder_board + Damage_capacitor);
    case 'WLTP'
        Range_to_Death = 23.266/(Damage_switch + Damage_bond + Damage_solder_board + Damage_capacitor);
    case 'USA_NECC'
        Range_to_Death = 1.899/(Damage_switch + Damage_bond + Damage_solder_board + Damage_capacitor);
    case 'EUROPE_CITY'
        Range_to_Death = 1.0044/(Damage_switch + Damage_bond + Damage_solder_board + Damage_capacitor);
    case 'USA_CITY_II'
        Range_to_Death = 6.2105/(Damage_switch + Damage_bond + Damage_solder_board + Damage_capacitor);    
    case 'ARTEMIS_150'
        Range_to_Death = 29.545/(Damage_switch + Damage_bond + Damage_solder_board + Damage_capacitor);
    case 'ARTEMIS_130'
        Range_to_Death = 28.7358/(Damage_switch + Damage_bond + Damage_solder_board + Damage_capacitor);
    case 'Max_Swing'
        Range_to_Death = 1/(Damage_switch + Damage_bond + Damage_solder_board);
    otherwise
        Range_to_Death = NaN;
end
if(~strcmp(Driving_Cycle_Name,'Max_Swing'))
    disp("the expected range until first failure is:" + num2str(floor(Range_to_Death)) + " km");
else
    disp("the expected cycle until first failure is:" + num2str(floor(Range_to_Death)) + " cycles");
end
disp("Inverter Type is: " + Inverter_Type);
disp("Driving Cycle is: " + Driving_Cycle_Name);


