clear;
close all;
clc;

U1 = 4; 
U2 = 6;
U3 = 8;
U4 = 10;
T1 = 2*10^-3;   % не на что не влияет, но так наверное просто правильнее. Если не забуду
T2 = 5*10^-3;   % поменяю в предыдущих лабах 
Fd = 5*10^3;
T = 1 / Fd;

%% Пункт 1 старые данные 

t1 = 0:T:T1;
t2 = T1+T:T:T2;
t = 0:T:T2;

x1 = U1 + (U2-U1)/T1*t1;
x2 = U3 + (U4-U3)/(T2-T1)*(t2-T1);
x = [x1 x2];

figure;
hold on;
stem(t,x,'b--');
title('The original signal');
xlabel('t, s');
ylabel('u(t), V');

%% Пункт 2 Расчёт ДПФ

n = 0:25;

x_dpf = fft(x); % вычислим ДПФ 

figure;

subplot(2,1,1);
stem(n,abs(x_dpf),'r-*'); % амплитудный 
grid on;
title('Graph of the spectral sampling module');
xlabel('n');
ylabel('|X(n)|');

subplot(2,1,2);
stem(n,angle(x_dpf),'r-*'); % фазовый 
grid on;
title('Phase graph of spectral samples');
xlabel('n');
ylabel('arg(X(n))');

%% Пункт 3 Оценка Ширины спектра сигнала 

E0 = sum(abs(x.^2)); % энергия исходного сигнала

x_dpf_2 = x_dpf;    % новая копия результата
Nmax = 0;   % некоторое пороговое значение 

x_dpf_2(Nmax+2:length(x_dpf_2)- Nmax) = 0; % обнуляем элементы копии, которые соответ гармоникам с номерами >N
x_opf = ifft(x_dpf_2); % используем ОПФ чтобы определить минимальное число низкочастотных гармонических
                % составляющих сигнала, содержащих не меньще 90% энергии 
% сделаем график указанного сигнала вместе с исходным
figure;
hold on;
stem(t, x, 'r--');
stem(t,x_opf,'b--*');
xlabel('t, с');
ylabel('u(t),V');
title('the original and restored signals');

E0_v = sum(abs(x_opf.^2)); % энергия получившегося сигнала 

E0_v/E0*100  % она меньше 90 ? 

% построим графики модуля и фазы для спектральных отсчётов сигнала,
% дополненного нулям. А надо ли? Вроде в задании нет, но я уже привык
% строить все, с чём провожу вычисления 
figure;
subplot(2,1,1);
stem(n,abs(x_dpf_2),'r-*');
grid on;
title('Graphic modyla spectralnih otschetov');
xlabel('n');
ylabel('|X(n)|');

subplot(2,1,2);
stem(n,angle(x_dpf_2),'r-*');
grid on;
title('Graphic phasi spectralnih otschetov');
xlabel('n');
ylabel('arg(X(n))')
% кстати, не зря, видимо, сделал. При обнулении предпреждали, что первое
% значение постоянная составляющая. И здесь её видно

%% Пункт 4 Дополнение сигнала нулями
%раньше обнуляли, теперь дополняем

n=0:51; % чтобы длина исходного дискретного сигнала стала больше вдвое &&&&&&&&&

x_with_null = [x, zeros(1, length(x))]; %заполняем нулями вторую часть в новую переменную исходного
                                % дискретного сигнала

x_with_null_dpf = fft(x_with_null);    % вычисляем ДПФ 

% построим графики и модуля фазы 
figure;
hold on;

subplot(2,1,1);
stem(n,abs(x_with_null_dpf), 'r-*');
xlabel('n');
ylabel('|X(n)|');
title('graph of the module of spectral samples of the signal supplemented with zeros');
grid on;
xlim([0 52]); % почему то по оси Х 60 значений 

subplot(2,1,2);
stem(n,angle(x_with_null_dpf), 'b-*');
xlabel('n');
ylabel('arg(X(n))');
title('phase graph of spectral samples of a signal supplemented with zeros');
grid on;
xlim([0 52]);

%% Пункт 5 Изменение скорости расчётов при вычислении ДПФ непосредственно по теор формуле

% для удобства создадим цикл
step_two = 6:13;  % степени для двойки (к таблице 3.2)
N = 2.^step_two;   % размер ДПФ - сюда же те же степени
for i = 1:8 % цикл для 8 значений - как в таблице 3.2
    x1 = [x zeros(1, N(i) - length(x))]; % дополнение сигнала нулями до длины N
    D = dftmtx(N(i)); % матрица ДПФ 
    y = zeros(1,N(i)); % массив для результатов ДПФ 
    tic                % старт таймера 
    for k = 1:650     % цикл для измерения времени при 2000 - 3сек, надо 1 сек, при 3000 - 4.5
                       % 1.5 при 1000, 1.1 при 750
        y = x1*D;      % вычисление ДПФ по прямой формуле   
    end
    t_r(i) = toc;       % отображение времени i-той итерации (8 штук)
end
t_r1 = t_r./1000;        % делим для удобство при построении графика ? чтобы совпасть с t теор
tteor = 0.9*N.^2*10^(-9); % для того, чтобы построить зависимость теории от расчёта 
                          % зависимостей прямого ДПФ, получим при N = 1024
                          % и 8192. коэф К подберём 

figure;
hold on;

semilogy(log2(N),(t_r1),'r-*'); % позволяет строить графики по ОХ линейно, а по ОУ логорифмически
semilogy(log2(N),tteor,'b--');

xlabel('log2(N)');
ylabel('t,s');
legend('Эксперимент','Теория');
grid on;

%% Пункт 6 Измерение скорости расчётов при вычислении ДПФ с использованием быстро алгоритма
% аналогичный цикл. N уже указан выше. Заполнять нулями уже нет потребности
for i = 1:8
    y = zeros(1,N(i)); % массив для результатов 
    tic                % старт таймера
    for k = 1:180000   % цикл для измерения времени при 350к на нужном 1.8сек. при 400к 2.1
                       % 1.3 при 250к. 0.95 при 150к
        y = fft(x,N(i)); % вычисление БПФ 
    end
    t_r_6(i)=toc;        % отображение измеренного времени 
end

t_r1_6 = t_r_6./370000;   % так же подвожим под график теор 
tteor2 = 0.25*N.*log2(N)*10^(-9); % теор

figure;
hold on;

semilogy(log2(N),t_r1_6,'r-*');
semilogy(log2(N),tteor2,'b--');

xlabel('log2(N)');
ylabel('t,s');
legend('Эксперимент','Теория');
grid on;









    