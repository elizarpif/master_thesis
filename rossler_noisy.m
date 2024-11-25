% Coupling params
Ex = 0.15;  % X->Y
Ey = 0;  % Y->X

% Natural frequencies
wx = 1.1;
wy = 0.9;

% 
couplingX_values = [0, logspace(log10(0.001), log10(0.01), 10)];
runNumber = 10;
isPlotX1Y1 = false;

L_YX_values_mean = zeros(size(couplingX_values));
L_XY_values_mean = zeros(size(couplingX_values)); 
R_values_mean = zeros(size(couplingX_values));

L_XY_values_N = zeros(length(couplingX_values), runNumber);
L_YX_values_N = zeros(length(couplingX_values), runNumber);
R_values_N = zeros(length(couplingX_values), runNumber);

tic
% Loop over coupling strengths
for idx = 1:length(couplingX_values)
    L_YX_values = zeros(runNumber, 1);
    L_XY_values = zeros(runNumber, 1);
    R_values = zeros(runNumber, 1);

    for runIdx = 1:runNumber
        couplingX = couplingX_values(idx);
        res = Rossler(couplingX, Ey, wx, wy, isPlotX1Y1);

        %% L metric
        k = 5;
        theiler_correction = 50;
        tau = 4;
        m=8;
        %
        datarec = [res; res]';
        Lmetric = HSLMNCom(datarec,m,tau,k,theiler_correction);

        L_YX_values(runIdx) = Lmetric(2,1);
        L_XY_values(runIdx) = Lmetric(2,2);

        %% R metric 
        Rmetric = EA_MeanPhaseCoherence(datarec');
        R_values(runIdx) = Rmetric;

    end

    L_YX_values_mean(idx) = mean(L_YX_values);
    L_XY_values_mean(idx) = mean(L_XY_values);
    R_values_mean(idx) = mean(R_values);

    L_XY_values_N(idx, :) = L_XY_values;
    L_YX_values_N(idx, :) = L_YX_values;
    R_values_N(idx, :) = R_values;
end
toc

% Plot all runs and the mean for L_XY_values
figure(1);
hold on;
for idx = 1:size(L_XY_values_N, 2)
    plot(couplingX_values, L_XY_values_N(:, idx), 'Color', [0.8, 0.8, 0.8]); % All individual runs in light gray
end
plot(couplingX_values, L_XY_values_mean, 'b', 'LineWidth', 2); % Mean in red
xlabel('Coupling Ex');
ylabel('L_{XY}');
title('L_{XY} Metric: Individual Runs and Mean');
grid on;

% Plot all runs and the mean for L_YX_values
figure(2);
hold on;
for idx = 1:size(L_YX_values_N, 2)
    plot(couplingX_values, L_YX_values_N(:, idx), 'Color', [0.8, 0.8, 0.8]); % All individual runs in light gray
end
plot(couplingX_values, L_YX_values_mean, 'r', 'LineWidth', 2); % Mean in blue
xlabel('Coupling Ex');
ylabel('L_{YX}');
title('L_{YX} Metric: Individual Runs and Mean');
grid on;

% Plot all runs and the mean for R_values
figure(3);
hold on;
for idx = 1:size(R_values_N, 2)
    plot(couplingX_values, R_values_N(:, idx), 'Color', [0.8, 0.8, 0.8]); % All individual runs in light gray
end
plot(couplingX_values, R_values_mean, 'g', 'LineWidth', 2); % Mean in green
xlabel('Coupling Ex');
ylabel('R');
title('R Metric: Individual Runs and Mean');
grid on;

% plot 3 metrics
figure(4);
plot( ...
    couplingX_values, L_XY_values_mean, 'b', ...
    couplingX_values, L_YX_values_mean, 'r', ...
    couplingX_values, R_XY_values_mean, 'g' ...
    );
legend('L(X|Y)', 'L(Y|X)', 'R');
xlabel('E_x');
ylabel('mean metric');
title('mean L and R depending on coupling strength');
grid on;

%% Rossler 
function res = Rossler(Ex, Ey, wx, wy, isPlotX1Y1)
x0 = rand(3,1);
y0 = rand(3,1);

h = 0.03; % integration step
n_steps = 10240*2;    
t = 0:h:(n_steps-1)*h;

x_res = zeros(3, n_steps);
y_res = zeros(3, n_steps);
x_res(:, 1) = x0;
y_res(:, 1) = y0;

for i = 1:n_steps-1
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

% deminish transients
x_res2 = x_res(:, length(x_res)-10240:length(x_res));
y_res2 = y_res(:, length(x_res)-10240:length(y_res));
t_2 = t(length(t)-10240:length(t));

% Generate uncorrelated white Gaussian noise
noise = randn(size(x_res2(1,:))); % Zero mean, unit variance
noisy_x = x_res2(1,:) + noise;

noise = randn(size(y_res2(1,:))); % Zero mean, unit variance
noisy_y = y_res2(1,:) + noise;

res = [noisy_x; noisy_y];

if isPlotX1Y1 
   plot_x1_vs_y1(x_res2, y_res2, t_2, Ex);
end

end

%% Plot x1 vs y1
function plot_x1_vs_y1(x_res, y_res, t, Ex)
figure;
    % t, x_res, 'b', ...
plot( t, x_res, 'b', ...
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