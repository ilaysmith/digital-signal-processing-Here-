clc;
clear;
close all;

%fdatool
% создадим ИХ идеального фильтра 
    
fstop = 0.96 * 10^3; % из заданных параметров 

Fs = 4.8*10^3;
t = 0:1/Fs:4.8*10^-3;            % от нуля до Fs = 4800
u = sin(2*pi*fstop*t)./(2*pi*fstop*t); % запишем sinc

u(1) = 1;

figure;
stem(t,u,'r-');   % построим от stem
ylabel('u(t)');
title('ИХ идеального ФНЧ');
xlabel('t,s');
grid on;

figure;
plot(t,u,'r-'); % построим от plot
ylabel('h(t)');
title('ИХ идеального ФНЧ');
xlabel('t,s');
grid on;

% если построить и АЧХ то тоже получается интересно, там получаются ровные
% линии, а на фазовом просто одна прямая 
