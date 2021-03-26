function [li_out, ampl, phy] = cal_lock_in( li_input, li_angle, li_phase)
%% test module
% clear all; clc
% LIangle = (0:10:359)/180*pi; LIangle = LIangle(:);
% LIinput = 15*(1+cos(2*(LIangle - 128/180*pi))); LIinput = LIinput(:);
% LIphase = (0 : 3 : 179)/180*pi;
%% calculate lock in signal
for kk = 1 : length(li_phase)
    refer = cos( 2*(li_angle - li_phase(kk)));
    refer = refer(:);
    li_out(kk) = 2*sum(refer.*li_input)/length(li_angle);
%     figure(1)
%     hold off
%     plot(refer*100, 'r')
%     hold on
%     plot(LIinput, 'b')
%     detect(:,2) = refer;
%     detect(:,1) = LIinput;
%     detect(:,3) = refer.*LIinput;
end    
%% calculate phase: fft
y = fft( li_out);
power = y.*conj(y)/(length(li_out)^2);
ampl = 2*sqrt(power(2));
phase = angle(y);
alpha = phase(2)/pi*180/2;
phy = mod(-alpha,180);
% figure(2)
% plot( LIangle, LIinput, 'b')
% hold on
% plot( LIphase, LIout, 'g')
% hold off