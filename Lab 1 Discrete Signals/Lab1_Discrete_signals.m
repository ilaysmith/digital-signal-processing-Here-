clc;
clear; % чтобы не было повторного определения перменных
close all; % чтобы избежать увеличения числа окон после запуска 

%%
% Параметры Пункт 1
U1 = 4;
U2 = 6;
U3 = 8;
U4 = 10;
T1 = 2;
T2 = 5;
Fd = 5;     % частота дискретизации
            % kx - отсчёты аналогово сигнала 
%%
%Создание дискретного сигнала Пункт 2
T = 1/Fd;       % интервал дискретизации 
                
t = 0:T:T2; % от 0 с шагом T до Т2 общий вектор для графиков 
t1 = 0:T:T1; % от 0 с шагом Т до Т1 - на графике s(t) первый кусок 
t2 = T1+T:T:T2;  % от T1 с шагом Т до Т2 - на s(t) второй кусок % T1+T тк T1 уже учли в t1

k1 = (U2-U1)/(T1-0)*t1 + U1; % коэф наклона ()/() * вектор + пересечение с OY 
k2 = (U4-U3)/(T2-T1)*(t2-T1) + U3; % из уравнения прямой нашли коэф наклона()/()*вектор + пересечение OY
% для k2 задали t = (t2 - T1) тк построение начинаем раньше --> U3 должен
% равняться 7, а, если не писать - Т1, то он равен 4 --> получилось то что
% подняли график

kx = [k1 k2]; % зададим массив линейных отсчётов u1 и u2 

% зададим график 
figure;   % пустая фигура 
hold on;   % режим сохранения графика 
plot(t,kx,'r-'); % график u от t с цветом красным
stem(t,kx,'b--'); % для построения графика дискретного сигнала - вертикальные стебельки с цветом синим
title('Discrete signal'); % подпись 
xlabel('t, ms'); % по оси x 
ylabel('S(t), V'); % по оси y подпись 

%%
% график спектра дискретного сигнала Пункт 4
N = length(kx); % длина вектора 
k = (0:N-1).'; % сформировали вектор-столбец номеров отсчётов .' транспонирование 
w_step = pi/500; % шаг чтобы поместилось в диапазон 100 элементов (500 от -pi до 0 и 500 от 0 до pi)
w = -pi:w_step:pi; % вектор-строка равномерно расположенных частот для расчёта спектра

W = length(w); % длина вектора w
disp(W); % выведем его длину для проверки правильности задания w_step и w -- 1001 = 1000 + 1 (это 0)

matrix_kw = k*w; % столбец k и строка w - попарные произведения k и w - матрица k на w
matrix_kw = matrix_kw*(-1i); % -j умножаем на матрицу 

% функция exp обрабатывает матричные значения поэлементно 

e = exp(matrix_kw); % значение комплексной экспоненты из формулы 1.3

xW = kx*e; % вектор-строка значений спектра для M частот из вектора w: k(x) * e^(-jkw)

f = Fd*w/(2*pi); % линейная частота 

figure; % пустая фигура - новое граф окно --- Построим графики 

subplot(2, 1, 1); % делим граф окно
module_xW = abs(xW); % вычисление модуля 
plot(f, module_xW, 'r'); % построение графика 
xlabel('f, kHz'); % подпись по ОХ
ylabel('|A(f)|'); % подпись по ОУ
title('Amplitude Spectrum'); % подпись графика 

subplot(2,1,2);       % делим граф окно 
phase_xW = angle(xW);  % вычесление аргумента(фазы)
plot(f, phase_xW, 'k');
xlabel('f, kHz');   % подпись по ОХ
ylabel('arg(A(f))');    % подпись по ОУ
title('Phase Specrtum');      % подпись графика

%%
% По теореме Котельникова восстановим аналоговый сигнал Пункт 5

t_restored = (-5*T):(T/10):(T2+T*5); % вектор моментов времени для расчёта восст-ого сигнала по 1.5
                             % шаг в 10 раз меньше и выходит за края, чтобы
                             % увидеть затухающие хвосты six(x)/x
length_t = length(t_restored);      % длина вектора моментов времени
Vector_values = zeros(1, length_t); % загтовка с нулями для вектора значений восстановленного
                                     % сигнала s(t)
% запишем цикл: к заготовки прибавляется очередное слагаемое из форумулы 1.5
for k_step= 1:N            % повторить N раз вычисление суммы по k: это длина спектра из Пункта 2 
    Vector_values = Vector_values + kx(k_step).*sinc((t_restored-(k_step-1).*T)./T); % T-интервал дискретизации
end % расставили точки перед * и / чтобы действия происходили поэлементно тк слагаемые 1.5 
    % рассчитываются сразу для всех моментов времени t
    % так же использовали sinc чтобы извабиться от разрывов 

% выведем графики 

figure;
hold on;

plot(t_restored,Vector_values,'r-'); % исходный дискретный сигнал
stem(t,kx,'b-');             % аналоговый сигнал 

title('The original and restored signals');
xlabel('t, ms');
ylabel('S(t),V');

