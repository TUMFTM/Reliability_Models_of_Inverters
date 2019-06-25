function [Nf] = Board_Reliability(board_param, duration, board_temp_series)
    D = board_param.D;
    rou = board_param.rou;
    a = board_param.a;
    b = board_param.b;
    point_number = board_param.point_number;
    amplitude = board_param.amplitude; %maximum vibration
    board_number = board_param.board_number;
    %vibration parameters loaded
    
    f0 = pi/2*sqrt(D/rou*(2.45/a^4 + 2.32/a^2/b^2 + 1/b^2));%natural frequency of a rectangular board
    %this is right now online source, but can be replaced by book of mechanic basics
    d = amplitude/4/pi^2/f0;%maximum deformation amplitude
    per_point_life = exp((0.812 - d)/0.0215)/1000*2*100/20;%life of a solder point in hours
    Board_Life_V = per_point_life; 
    Nf_V = Board_Life_V/duration;%translate to cycle life
    %vibration life estimation done
    %the model is obtained from ref: Vibration reliability of SMD Pb-free solder joints
    
    [Tam,Top,FF,MEAN] = get_idle_andpeak(board_temp_series);
    %thermal life parameters loaded, and processed to aging cycles
    
    %assuming with 0805/0402/0603 pads
    packagedata.h = 0.14 * 1e-3 / 3;
    packagedata.L = 0.14 * 1e-3;
    packagedata.alpha = 25e-6 - 16.7e-6;
    %difference of copper and solder, where the highest tense will be caused

    Nf_T = ENGELMAIER_solder(packagedata,Tam,Top,FF,MEAN);
    %temperature life estimation done

    Nf = 1/(sum(1./Nf_T) + 1/Nf_V)/point_number/board_number;
    %final result of the board solder reliability obtained
end


