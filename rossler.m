% Coupling params
Ex = 0.15;  % X->Y
Ey = 0;  % Y->X

% Natural frequencies
wx = 1.1;
wy = 0.9;

res = Rossler(Ex, Ey, wx, wy);

%% Coupling (0.1, 0.3)
% couplingX_values = logspace(log10(0.001), log10(0.3), 30);
% % couplingInc = 0.01;
% % couplingX_values = 0:couplingInc:Ex; % Coupling strengths
% runNumber = 1;
% 
% tic
% 
% L_YX_values_mean = zeros(size(couplingX_values)); % Preallocate delta L results
% L_XY_values_mean = zeros(size(couplingX_values)); % Preallocate delta L results
% R_XY_values_mean = zeros(size(couplingX_values));
% 
% 
% % Loop over coupling strengths
% for idx = 1:length(couplingX_values)
% 
%     L_YX_values = zeros(size(runNumber)); % Preallocate delta L results
%     L_XY_values = zeros(size(runNumber)); % Preallocate delta L results
%     R_XY_values = zeros(size(runNumber));
% 
% 
%     for runIdx = 1:runNumber
%         couplingX = couplingX_values(idx);
%         res = Rossler(couplingX, Ey, wx, wy);
% 
% 
%         %% L metric
%         k = 5;
%         theiler_correction = 50;
%         tau = 4;
%         m=8;
%         %
%         datarec = [res(1,:); res(4,:)]';
%         Lmetric = HSLMNCom(datarec,m,tau,k,theiler_correction);
% 
%         % deltaL = metric(2,2); %  - metric(2,1);
% 
%         L_YX_values(runIdx) = Lmetric(2,1);
%         L_XY_values(runIdx) = Lmetric(2,2);
% 
%         Rmetric = EA_MeanPhaseCoherence(datarec');
%         R_XY_values(runIdx) = Rmetric;
% 
%     end
% 
%     L_YX_values_mean(idx) = mean(L_YX_values);
%     L_XY_values_mean(idx) = mean(L_XY_values);
%     R_XY_values_mean(idx) = mean(R_XY_values);
% end
% toc
% 
% figure;
% plot( ...
%     couplingX_values, L_XY_values_mean, 'b', ...
%     couplingX_values, L_YX_values_mean, 'r', ...
%     couplingX_values, R_XY_values_mean, 'g' ...
%     );
% legend('L(X|Y)', 'L(Y|X)', 'R');
% xlabel('E_x');
% ylabel('metric');
% title('L and R depending on coupling strength');
% grid on;

%% Rossler 
function res = Rossler(Ex, Ey, wx, wy)
x0 = rand(3,1);
y0 = rand(3,1);
% x0 = [1; 0; 0];  % Начальные значения для системы X
% y0 = [1; 0; 0];  % Начальные значения для системы Y

% Время интеграции
h = 0.03;           % integration step
n_steps = 10240*2;    % Количество точек (10240)
t = 0:h:(n_steps-1)*h;

% Инициализация массивов для хранения решений
x_res = zeros(3, n_steps);
y_res = zeros(3, n_steps);
x_res(:, 1) = x0;
y_res(:, 1) = y0;

for i = 1:n_steps-1
    % Текущее состояние
    x_current = x_res(:, i);
    y_current = y_res(:, i);

    % Вычисление k1 для обеих систем
    k1_x = h * rossler_eq(x_current, wx, Ey, y_current(1));
    k1_y = h * rossler_eq(y_current, wy, Ex, x_current(1));

    % Вычисление k2 для обеих систем
    k2_x = h * rossler_eq(x_current + k1_x / 2, wx, Ey, y_current(1) + k1_y(1) / 2);
    k2_y = h * rossler_eq(y_current + k1_y / 2, wy, Ex, x_current(1) + k1_x(1) / 2);

    % Вычисление k3 для обеих систем
    k3_x = h * rossler_eq(x_current + k2_x / 2, wx, Ey, y_current(1) + k2_y(1) / 2);
    k3_y = h * rossler_eq(y_current + k2_y / 2, wy, Ex, x_current(1) + k2_x(1) / 2);

    % Вычисление k4 для обеих систем
    k4_x = h * rossler_eq(x_current + k3_x, wx, Ey, y_current(1) + k3_y(1));
    k4_y = h * rossler_eq(y_current + k3_y, wy, Ex, x_current(1) + k3_x(1));

    % Обновление значений для x и y систем
    x_res(:, i+1) = x_current + (k1_x + 2 * k2_x + 2 * k3_x + k4_x) / 6;
    y_res(:, i+1) = y_current + (k1_y + 2 * k2_y + 2 * k3_y + k4_y) / 6;
end
%% Plot y1, y2, y3
% subplot(3,1,1);
% plot(t, y_res(1, :));
% xlim([min(t), max(t)]);
% % title('y_1(t)');
% xlabel('Time');
% ylabel('y_1');
%
% subplot(3,1,2);
% plot(t, y_res(2, :));
% xlim([min(t), max(t)]);
% % title('y_2(t)');
% xlabel('Time');
% ylabel('y_2');
%
% subplot(3,1,3);
% plot(t, y_res(3, :));
% xlim([min(t), max(t)]);
% % title('y_3(t)');
% xlabel('Time');
% ylabel('y_3');
% grid on;
% %
%% Plot 3d x
% figure;
% plot3(x_res(1,:), x_res(2,:), x_res(3,:));
% xlabel('X');
% ylabel('Y');
% zlabel('Z');
% title('3D Plot Example');
% grid on;

x_res2 = x_res(:, length(x_res)-10240:length(x_res));
y_res2 = y_res(:, length(x_res)-10240:length(y_res));
t_2 = t(length(t)-10240:length(t));

% Generate uncorrelated white Gaussian noise
noise = randn(size(x_res2(1,:))); % Zero mean, unit variance
noisy_x = x_res2(1,:) + noise;

noise = randn(size(y_res2(1,:))); % Zero mean, unit variance
noisy_y = y_res2(1,:) + noise;

res = [noisy_x; noisy_y];

plot_x1_vs_y1(noisy_x, noisy_y, t_2, Ex);
end

%% Plot x1 vs y1
function plot_x1_vs_y1(x_res, y_res, t, Ex)
figure;
plot(t, x_res, 'b', ...
    t, y_res, 'r' ...
    ); % 'b' и 'r' задают цвета кривых
xlim([min(t), max(t)]);
xlabel('Time');
ylabel('Values');
legend('x_1', 'y_1');
title(sprintf('Rossler: x_1 and y_1, coupling Ex = %f', Ex));
grid on;

end

% Params:
% x - 3-d vector
% w_freq - natural wrequency, when the system oscillate
% coupling - coupling value, (for the system X it will be Ey)
% coupled_var (for the system X it will be y1)
function rez = rossler_eq(x, w_freq, coupling, coupled_var)
a = 0.15; %0.2;
b = 0.2;
c = 10; %5.7;

% Дифференциальные уравнения с учётом частоты и связи
dx1dt = -w_freq * x(2) - x(3) + coupling * (coupled_var - x(1));
dx2dt = w_freq * x(1) + a * x(2);
dx3dt = b + x(3) * (x(1) - c);

rez = [dx1dt; dx2dt; dx3dt]; % Возвращаем вектор производных
end