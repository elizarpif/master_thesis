%% Parameters for noisy Rossler
Ey=0;
% Natural frequencies
wx = 1.1;
wy = 0.9;

couplingX_values = [0, logspace(log10(0.01), log10(1), 30)]; % Coupling strengths

numRuns = 20; % Number of runs for averaging
isPlotX1Y1 = false; % Option to plot dynamics

% Preallocate results
L_YX_mean = zeros(size(couplingX_values));
L_XY_mean = zeros(size(couplingX_values));
R_mean = zeros(size(couplingX_values));

L_XY_all = zeros(length(couplingX_values), numRuns);
L_YX_all = zeros(length(couplingX_values), numRuns);
R_all = zeros(length(couplingX_values), numRuns);


%% Main loop over coupling strengths
tic
for idx = 1:length(couplingX_values)
    couplingX = couplingX_values(idx);

    L_YX_runs = zeros(numRuns, 1);
    L_XY_runs = zeros(numRuns, 1);
    R_runs = zeros(numRuns, 1);
    G_runs = zeros(numRuns, 1);
    S_runs = zeros(numRuns, 1);

    for runIdx = 1:numRuns
        % Simulate Rossler systems
        res1 = simulateRossler(couplingX, Ey, wx, wy);

        % Downsample and take only the last half
        [x_original, tx] = downsampleSignal(res1(1,:), res1(4,:), false);
        [y_original, ty] = downsampleSignal(res1(2,:), res1(4,:), false);

        l = 1;
        
        x = add_measurement_noise(x_original, l);
        y = add_measurement_noise(y_original, l);

        plot_x1_vs_noisy_x1(x_original, x, tx, "level = 1");

        datarec = [x; y]';

        % Compute L metric
        Lmetric = computeLMetric(datarec);

        log(sprintf("Ex = %f, run = %d, metric L computed", couplingX, runIdx));

        L_YX_runs(runIdx) = Lmetric(2, 1); % L(Y|X)
        L_XY_runs(runIdx) = Lmetric(2, 2); % L(X|Y)

        % Compute R metric
        R_runs(runIdx) = computeRMetric(datarec);
        log(sprintf("Ex = %f, run = %d, metric R computed", couplingX, runIdx));

    end

    % Compute mean metrics
    L_YX_mean(idx) = mean(L_YX_runs);
    L_XY_mean(idx) = mean(L_XY_runs);
    R_mean(idx) = mean(R_runs);

    % Store all runs for plotting
    L_XY_all(idx, :) = L_XY_runs;
    L_YX_all(idx, :) = L_YX_runs;
    R_all(idx, :) = R_runs;
end
toc

%% Plot results
plotMetricResults(couplingX_values, L_XY_all-L_YX_all, L_XY_mean-L_YX_mean, 'delta L')
% Combined plot for mean metrics
% couplingX_values, L_XY_mean-L_YX_mean, 'c', ...
figure;
plot(couplingX_values, L_XY_mean, 'b', ...
    couplingX_values, L_YX_mean, 'r', ...
    couplingX_values, R_mean, 'g', 'LineWidth', 1);
legend('L(X|Y)', 'L(Y|X)', ...
    'R');
xlabel('Coupling E_x');
ylabel('Mean metric value');
title('');
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
% plot(t(end-4096*3:end), x_res(1, end-4096*3:end));
% xlim([t(end-4096*3), t(end)]);
% % xlabel('Time');
% ylabel('x_1');
% 
% subplot(3,1,2);
% plot(t(end-4096*3:end), x_res(2, end-4096*3:end));
% xlim([t(end-4096*3), t(end)]);
% % xlabel('Time');
% ylabel('x_2');
% 
% subplot(3,1,3);
% plot(t(end-4096*3:end), x_res(3, end-4096*3:end));
% xlim([t(end-4096*3), t(end)]);
% ylabel('x_3');
% xlabel('Time');

end

function [x_noisy] = addNoise(x, l)
% 
% Generate uncorrelated white Gaussian noise
noise = randn(size(x(1,:))); % Zero mean, unit variance

% Modify the amplitude distribution by raising noise to the power of l
modified_noise = noise.^l;

% wthout normalizing modified_noise (I don't understand why it should be)
% modified_noise = normalize(modified_noise);

snr = var(x)/var(modified_noise);

log(sprintf("SNR=%f", snr));

x_noisy = x(1,:) + snr*modified_noise; 
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

function G = computeGMetric(y, y_aux)
    % Compute G metric based on phase difference between y and y_aux
    phase_y = instantaneous_phase(y);
    phase_y_aux = instantaneous_phase(y_aux);
    G = abs(sin((phase_y - phase_y_aux) / 2));
end

function S = computeSMetric(x, y)
    % Compute S metric based on phase difference accumulation
    phase_x = instantaneous_phase(x);
    phase_y = instantaneous_phase(y);
    delta_phase = unwrap(phase_x) - unwrap(phase_y);
    S = (max(delta_phase) - min(delta_phase)) / (2 * pi);
end

function instantaneous_phase=instantaneous_phase(x)
% Compute the analytic signal using the Hilbert transform
analytic_signal = hilbert(x);
% Compute the instantaneous phase
instantaneous_phase = angle(analytic_signal);
end


%% Plot x1 vs noisy_x1
function plot_x1_vs_noisy_x1(x_res, y_res, t, titlePlot)
figure;
    % t, x_res, 'b', ...
plot( t(end-200:end), x_res(end-200:end), 'b', ...
      t(end-200:end), y_res(end-200:end), 'r' ...
    ); % 'b' и 'r' задают цвета кривых
xlabel('Time');
ylabel('Values');
xlim([t(end-200), t(end)]);
legend('x_1', 'noisy x_1');
title(sprintf('Rossler: x_1 and noisy x_1, %s', titlePlot));
grid on;

end