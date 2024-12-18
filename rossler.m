%% Parameters
Ey=0;
% Natural frequencies
wx = 1.1;
wy = 0.9;

couplingX_values = [logspace(log10(0.01), log10(0.7), 20)]; % Coupling strengths
numRuns = 20; % Number of runs for averaging
isPlotX1Y1 = false; % Option to plot dynamics

% res = simulateRossler(Ex, Ey, wx, wy);
% x = downsampleSignal(res(1,:), res(3,:), isPlotX1Y1);
% y = downsampleSignal(res(2,:), res(3,:), isPlotX1Y1);

% Preallocate results
L_YX_mean = zeros(size(couplingX_values));
L_XY_mean = zeros(size(couplingX_values));
R_mean = zeros(size(couplingX_values));
G_mean = zeros(size(couplingX_values));

L_XY_all = zeros(length(couplingX_values), numRuns);
L_YX_all = zeros(length(couplingX_values), numRuns);
R_all = zeros(length(couplingX_values), numRuns);
G_all = zeros(length(couplingX_values), numRuns);

%% Main loop over coupling strengths
tic
for idx = 1:length(couplingX_values)
    couplingX = couplingX_values(idx);

    L_YX_runs = zeros(numRuns, 1);
    L_XY_runs = zeros(numRuns, 1);
    R_runs = zeros(numRuns, 1);
    G_runs = zeros(numRuns, 1);

    for runIdx = 1:numRuns
        % Simulate Rossler systems

        % log(sprintf("Ex = %f, run = %d, simulate Rossler started", couplingX, runIdx));
        res = simulateRossler(couplingX, Ey, wx, wy);
        % log(sprintf("Ex = %f, run = %d, simulate Rossler finished", couplingX, runIdx));

        % Downsample and take only the last half
        [x, tx] = downsampleSignal(res(1,:), res(4,:), false);
        [y, ty] = downsampleSignal(res(2,:), res(4,:), false);
        [y_aux, ty_aux] = downsampleSignal(res(3,:), res(4,:), false);
        % log(sprintf("Ex = %f, run = %d, downsample finished", couplingX, runIdx));

        % if isPlotX1Y1
        %     figure;
        %     plot(tx, x, 'b', ty, y, 'r');
        %     xlabel('Time');
        %     ylabel('Values');
        %     legend('x_1', 'y_1');
        %     title(sprintf('Rossler: x_1 and y_1 Dynamics with E_x = %.3f, E_y = %.3f', couplingX, Ey));
        %     grid on;
        % end
        % Use only the first variables of x and y
        datarec = [x; y]';

        % Compute L metric
        Lmetric = computeLMetric(datarec);

        log(sprintf("Ex = %f, run = %d, metric L computed", couplingX, runIdx));


        L_YX_runs(runIdx) = Lmetric(2, 1); % L(Y|X)
        L_XY_runs(runIdx) = Lmetric(2, 2); % L(X|Y)

        phasey1 = instantaneous_phase(y);
        phasey2 = instantaneous_phase(y_aux);

        G = abs(sin((phasey1-phasey2)/2));
        G_runs(runIdx) = mean(G);
        log(sprintf("Ex = %f, run = %d, delta=%f", couplingX, runIdx, mean(G)));


        % Compute R metric
        R_runs(runIdx) = computeRMetric(datarec);
        log(sprintf("Ex = %f, run = %d, metric R computed", couplingX, runIdx));

    end

    % Compute mean metrics
    L_YX_mean(idx) = mean(L_YX_runs);
    L_XY_mean(idx) = mean(L_XY_runs);
    R_mean(idx) = mean(R_runs);
    G_mean(idx) = mean(G_runs);

    % Store all runs for plotting
    L_XY_all(idx, :) = L_XY_runs;
    L_YX_all(idx, :) = L_YX_runs;
    R_all(idx, :) = R_runs;
    G_all(idx,:) = G_runs;
end
toc

%% Plot results
plotMetricResults(couplingX_values, L_XY_all, L_XY_mean, 'L_{XY}');
plotMetricResults(couplingX_values, L_YX_all, L_YX_mean, 'L_{YX}');
plotMetricResults(couplingX_values, G_all, G_mean, 'G');
plotMetricResults(couplingX_values, R_all, R_mean, 'R');

plotMetricResults(couplingX_values, L_XY_all-L_YX_all, L_XY_mean-L_YX_mean, 'delta L')
% Combined plot for mean metrics
% couplingX_values, L_XY_mean-L_YX_mean, 'c', ...
figure;
plot(couplingX_values, L_XY_mean, 'b', ...
    couplingX_values, L_YX_mean, 'r', ...
    couplingX_values, R_mean, 'g', 'LineWidth', 1);
% 'k' - black
% 'L(X|Y)-L(Y|X)', ...
legend('L(X|Y)', 'L(Y|X)', ...
    'R');
xlabel('Coupling E_x');
ylabel('Mean metric');
title('Mean L and R metrics vs coupling strength');
grid on;

%% Functions
function res = simulateRossler(Ex, Ey, wx, wy)
% Simulates two coupled Rossler systems with random initial conditions
x0 = rand(3, 1); % Random initial condition for system X
y0 = rand(3, 1); % Random initial condition for system Y
y0_aux = rand(3, 1); % Random initial condition for aux system Y

h = 0.03; % Integration step
nSteps = 100000; % Number of steps
t = 0:h:(nSteps-1)*h;

% Initialize solution arrays
x_res = zeros(3, nSteps);
y_res = zeros(3, nSteps);
y_res_aux = zeros(3, nSteps);
x_res(:, 1) = x0;
y_res(:, 1) = y0;
y_res_aux(:, 1) = y0_aux;

for i = 1:nSteps-1
    % Current state
    x_current = x_res(:, i);
    y_current = y_res(:, i);
    y_current_aux = y_res_aux(:, i);

    % Compute Runge-Kutta coefficients
    k1_x = h * rosslerEquation(x_current, wx, Ey, y_current(1));
    k1_y = h * rosslerEquation(y_current, wy, Ex, x_current(1));
    k1_y_aux = h * rosslerEquation(y_current_aux, wy, Ex, x_current(1));

    k2_x = h * rosslerEquation(x_current + k1_x/2, wx, Ey, y_current(1) + k1_y(1)/2);
    k2_y = h * rosslerEquation(y_current + k1_y/2, wy, Ex, x_current(1) + k1_x(1)/2);
    k2_y_aux = h * rosslerEquation(y_current_aux + k1_y_aux/2, wy, Ex, x_current(1) + k1_x(1)/2);


    k3_x = h * rosslerEquation(x_current + k2_x/2, wx, Ey, y_current(1) + k2_y(1)/2);
    k3_y = h * rosslerEquation(y_current + k2_y/2, wy, Ex, x_current(1) + k2_x(1)/2);
    k3_y_aux  = h * rosslerEquation(y_current_aux  + k2_y_aux /2, wy, Ex, x_current(1) + k2_x(1)/2);


    k4_x = h * rosslerEquation(x_current + k3_x, wx, Ey, y_current(1) + k3_y(1));
    k4_y = h * rosslerEquation(y_current + k3_y, wy, Ex, x_current(1) + k3_x(1));
    k4_y_aux = h * rosslerEquation(y_current_aux + k3_y_aux, wy, Ex, x_current(1) + k3_x(1));

    % Update state
    x_res(:, i+1) = x_current + (k1_x + 2*k2_x + 2*k3_x + k4_x) / 6;
    y_res(:, i+1) = y_current + (k1_y + 2*k2_y + 2*k3_y + k4_y) / 6;
    y_res_aux(:, i+1) = y_current_aux + (k1_y_aux + 2*k2_y_aux + 2*k3_y_aux + k4_y_aux) / 6;

end


res = [x_res(1,:); y_res(1,:); y_res_aux(1,:); t];

% figure;
% subplot(3,1,1);
% plot(t(end-4096*9:end), x_res(1, end-4096*9:end));
% xlim([min(t), max(t)]);
% % % title('y_1(t)');
% xlabel('Time');
% ylabel('y_1');
% 
% subplot(3,1,2);
% plot(t(end-4096*9:end), y_res(1, end-4096*9:end));
% xlim([min(t), max(t)]);
% % title('y_2(t)');
% xlabel('Time');
% ylabel('y_2');
% 
% subplot(3,1,3);
% plot(t(end-4096*9:end), y_res_aux(1, end-4096*9:end));
% xlim([min(t), max(t)]);
% ylabel('y_3');
% grid on;
%
end

function [x, t] = downsampleSignal(x_res, t, isPlotDynamics)
% in order to have approx 20 samples per cycle, downsample
ds_factor = 9;

% Downsample the x signal using the calculated rate
x_downsampled = x_res(1:ds_factor:end);
t_downsampled = t(1:ds_factor:end);

% and take only 4096 last samples
number_of_samples = 4096;
x = x_downsampled(end-number_of_samples+1: end);
t = t_downsampled(end-number_of_samples+1: end);

% Optional: Plot the downsampled signal
if isPlotDynamics
    figure;
    plot(t, x);
    title('Downsampled Signal');
    xlabel('Time');
    ylabel('Values');
    grid on;
end
end

function dxdt = rosslerEquation(x, w, coupling, coupledVar)
% Rossler equations with coupling
a = 0.15;
b = 0.2;
c = 10;

dx1 = -w*x(2) - x(3) + coupling * (coupledVar - x(1));
dx2 = w*x(1) + a*x(2);
dx3 = b + x(3)*(x(1) - c);

dxdt = [dx1; dx2; dx3];
end

function Lmetric = computeLMetric(data)
% Computes the L metric using HSLMNCom
m = 8;
tau = 4;
k = 5;
theiler_correction = 50;
Lmetric = HSLMNCom(data, m, tau, k, theiler_correction);
end

function Rmetric = computeRMetric(data)
% Computes the R metric using EA_MeanPhaseCoherence
Rmetric = EA_MeanPhaseCoherence(data');
end

function plotMetricResults(couplingValues, allRuns, meanValues, metricName)
% Plot individual runs and mean values for a given metric
figure;
hold on;
for runIdx = 1:size(allRuns, 2)
    plot(couplingValues, allRuns(:, runIdx), 'Color', [0.8, 0.8, 0.8]); % Individual runs in gray
end
plot(couplingValues, meanValues, 'LineWidth', 2); % Mean values
xlabel('Coupling E_x');
ylabel(metricName);
title(sprintf('%s Metric: Individual Runs and Mean', metricName));
grid on;
end

function log(message)
disp(sprintf("%s: %s", datestr(now, 'HH:MM:SS.FFF AM'), message));
end

function instantaneous_phase=instantaneous_phase(x)
% Compute the analytic signal using the Hilbert transform
analytic_signal = hilbert(x);
% Compute the instantaneous phase
instantaneous_phase = angle(analytic_signal);
end