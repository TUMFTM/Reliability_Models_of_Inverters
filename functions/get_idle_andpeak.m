function [Tam,Top,f,MEAN] = get_idle_andpeak(temp_curve)
%Obtain the peak value, and frequency in the profile
Tam = temp_curve(2);
index_start = 2;
counting = 0;
Top = 0;
f = 0;
MEAN = 0;
for i=3:length(temp_curve)
    if(abs(Tam- temp_curve(i))<0.1 &&(counting == 1))
        Top = [Top; max(temp_curve(index_start:i))];
        f = [f;1/(i - index_start)*24*3600];
        MEAN = [MEAN;mean(temp_curve(index_start:i))];
        index_start = i + 1;
        counting = 0;
    end
    if(abs(Tam- temp_curve(i))>=0.1 && (counting == 0))
        counting = 1;
    end
    if(abs(Tam- temp_curve(i))<0.1 && (counting == 0))
        index_start = i;
    end
end
MEAN = MEAN(2:length(MEAN));
f = f(2:length(f));
Top = Top(2:length(Top));
Tam = Tam.*ones(length(Top),1);

