
% Параметры систем Рёсслера
wx = 0.995;
wy = 1.015;
Ex = 2;  % Коэффициент связи для X
Ey = 0;  % Коэффициент связи для Y

% Начальные условия
x0 = rand(3,1);
y0 = rand(3,1);
% x0 = [1; 0; 0];  % Начальные значения для системы X
% y0 = [1; 0; 0];  % Начальные значения для системы Y

% Время интеграции
h = 0.01;           % Шаг
n_steps = 10240;    % Количество точек (10240)
t = 0:h:(n_steps-1)*h;

% Инициализация массивов для хранения решений
x_res = zeros(3, n_steps);
y_res = zeros(3, n_steps);
x_res(:, 1) = x0;
y_res(:, 1) = y0;

% Метод Эйлера для интеграции
for i = 1:n_steps-1
    % Текущее состояние
    x_current = x_res(:, i);
    y_current = y_res(:, i);

    % Вычисляем дифференциальные уравнения для системы X
    dx = rossler_eq(x_current, wx, Ey, y_current(1));

    % Вычисляем дифференциальные уравнения для системы Y
    dy = rossler_eq(y_current, wy, Ex, x_current(1));

    % Обновляем значения (метод Эйлера)
    x_res(:, i+1) = x_current + h * dx;
    y_res(:, i+1) = y_current + h * dy;
end

% Построение графиков системы X и Y
figure;
xlim([min(t), max(t)]);
subplot(3,1,1);
plot(t, y_res(1, :));
title('Система Y');
xlabel('Время');
ylabel('y_1(t)');

subplot(3,1,2);
plot(t, y_res(2, :));
title('Система Y');
xlabel('Время');
ylabel('y_2(t)');

subplot(3,1,3);
plot(t, y_res(3, :));
title('Система Y');
xlabel('Время');
ylabel('y_3(t)');
%

figure;
plot3(x_res(1,:), x_res(2,:), x_res(3,:));
xlabel('X');
ylabel('Y');
zlabel('Z');
title('3D Plot Example');
grid on;

% l = 1;
% r = 20*512;
% k = 5;
% theiler_correction = 30;
% tau = 8;
% % Вычисление метрики (например, кросс-корреляция)
% 
% datarec = [x_res, y_res];
% metric = HSLMNCom(datarec,m,tau,k,theiler_correction);
% % save only L(X|Y)
% L_values(m) = res(2,2);
% metric = xcorr(vx(1, :), vy(1, :), 'normalized');
% figure;
% plot(metric);
% title('Кросс-корреляция между системами X и Y');
% xlabel('Сдвиг');
% ylabel('Нормализованная корреляция');


% мне нужно сделать 2 ресслеровских системы,
% подкинуть инитиал параметры, решить систему импользуя метод Эйлера
% (Рунге-Кутты 4ого порядка) и получить сигнал из точек (10240 точек будет
% достаточно?) после этого посчитать метрику

% Params:
% x - 3-d vector
% w_freq - natural wrequency, when the system oscillate
% coupling
% coupled_var
function rez = rossler_eq(x, w_freq, coupling, coupled_var)
    a = 0.2;
    b = 0.2;
    c = 5.7;
    
    % Дифференциальные уравнения с учётом частоты и связи
    dxdt = -w_freq * x(2) - x(3) + coupling * (coupled_var - x(1));
    dydt = w_freq * x(1) + a * x(2);
    dzdt = b + x(3) * (x(1) - c);
    
    rez = [dxdt; dydt; dzdt]; % Возвращаем вектор производных
end