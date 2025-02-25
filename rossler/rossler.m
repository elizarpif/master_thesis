%% Parameters
Ey=0;
% Natural frequencies
wx = 1.1;
wy = 0.9;

couplingX_values = [0.1, 0.2, 0.3, 0.4]; % Coupling strengths

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
S_mean = zeros(size(couplingX_values));

L_XY_all = zeros(length(couplingX_values), numRuns);
L_YX_all = zeros(length(couplingX_values), numRuns);
R_all = zeros(length(couplingX_values), numRuns);
G_all = zeros(length(couplingX_values), numRuns);
S_all = zeros(length(couplingX_values), numRuns);


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
        [x, tx] = downsampleRosslerSignal(res1(1,:), res1(4,:), false);
        [y, ty] = downsampleRosslerSignal(res1(2,:), res1(4,:), false);

        % % Simulate Rossler systems
        res2 = simulateRossler(1, Ey, wx, wy);

        % Downsample and take only the last part
        [x2, tx2] = downsampleRosslerSignal(res2(1,:), res2(4,:), false);
        [y2, ty2] = downsampleRosslerSignal(res2(2,:), res2(4,:), false);
        % 
        % figure;
        % plot(tx, x, 'b', ty, y, 'r');
        % ylabel('Values');
        % xlim([tx(1), tx(250)])
        % xlabel('Time [a.u.]');
        % set(gcf,'position',[0,0,600,200])
        % lgd = legend('x_1', 'y_1', 'AutoUpdate', 'off', 'Location', 'northeastoutside');        % 
        % % figure;
        % plot(tx2, x2, 'b', ty2, y2, 'r');
        % ylabel('Values');
        % xlim([tx2(1), tx2(250)])
        % legend('x_1', 'y_1');
        % set(gcf,'position',[0,0,600,200])
        % xlabel('Time');

        [y_aux, ty_aux] = downsampleRosslerSignal(res1(3,:), res1(4,:), false);

        datarec = [x; y]';

        % Compute L metric
        Lmetric = computeLMetric(datarec, 1);

        logger(sprintf("Ex = %f, run = %d, metric L computed", couplingX, runIdx));

        L_YX_runs(runIdx) = Lmetric(1); % L(Y|X)
        L_XY_runs(runIdx) = Lmetric(2); % L(X|Y)

        G = computeGMetric(y, y_aux);
        G_runs(runIdx) = mean(G);
        logger(sprintf("Ex = %f, run = %d, delta=%f", couplingX, runIdx, mean(G)));

        S_runs(runIdx) = computeSMetric(x,y);
        logger(sprintf("Ex = %f, run = %d, S(phase diff)=%f", couplingX, runIdx, S_runs(runIdx)));

        % Compute R metric
        R_runs(runIdx) = computeRMetric(datarec);
        logger(sprintf("Ex = %f, run = %d, metric R computed", couplingX, runIdx));

    end

    % Compute mean metrics
    L_YX_mean(idx) = mean(L_YX_runs);
    L_XY_mean(idx) = mean(L_XY_runs);
    R_mean(idx) = mean(R_runs);
    G_mean(idx) = mean(G_runs);
    S_mean(idx) = mean(S_runs);

    % Store all runs for plotting
    L_XY_all(idx, :) = L_XY_runs;
    L_YX_all(idx, :) = L_YX_runs;
    R_all(idx, :) = R_runs;
    G_all(idx,:) = G_runs;
    S_all(idx,:) = S_runs;
end
toc

%% Plot results
% plotMetricResults(couplingX_values, L_XY_all, L_XY_mean, 'L_{XY}');
% plotMetricResults(couplingX_values, L_YX_all, L_YX_mean, 'L_{YX}');
% plotMetricResults(couplingX_values, R_all, R_mean, 'R');
% plotMetricResults(couplingX_values, L_XY_all-L_YX_all, L_XY_mean-L_YX_mean, 'delta L')

figure;
plot(couplingX_values, G_mean, 'r', ...
    'LineWidth', 1);
xlabel('Coupling E_x');
ylabel('Mean G metric');
legend('G mean');
title(sprintf("G metric (generalized sync)"));
grid on;

figure;
semilogy(couplingX_values, G_mean, 'r-o', 'LineWidth', 1);
xlabel('Coupling E_x');
ylabel("Mean metric");
title(sprintf("Mean delta between Y and Y\'"));
grid on;

% figure;
% plot(couplingX_values, S_mean, 'r', 'LineWidth', 1);
% xlabel('Coupling E_x');
% ylabel('Mean S metric');
% title(sprintf("S metric, accumulated order parameter phase difference"));
% grid on;

% figure;
% plot(couplingX_values, R_mean, 'r', 'LineWidth', 1);
% xlabel('Coupling E_x');
% ylabel('Mean R metric');
% title(sprintf("R metric, mean phase coherence"));
% grid on;
% % Combined plot for mean metrics
% % couplingX_values, L_XY_mean-L_YX_mean, 'c', ...
% figure;
% plot(couplingX_values, L_XY_mean, 'b', ...
%     couplingX_values, L_YX_mean, 'r', ...
%     couplingX_values, R_mean, 'g', 'LineWidth', 1);
% legend('L(X|Y)', 'L(Y|X)', ...
%     'R');
% xlabel('Coupling E_x');
% ylabel('Mean metric value');
% title('');
% grid on;

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
% phase = (atan2(imag(analytic_signal),real(analytic_signal)));
% if instantaneous_phase ~= phase 
%     log("instantaneous phase diff %v != %v", instantaneous_phase,phase )
% end
end