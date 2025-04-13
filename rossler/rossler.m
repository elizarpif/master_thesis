%% Parameters
Ey=0;
% Natural frequencies
wx = 0.995;
wy = 1.015;

%  logspace(log10(0.01), log10(1), 30)
couplingX_values = [0,logspace(log10(0.01), log10(1), 30)]; % Coupling strengths

numRuns = 20; % Number of runs for averaging
isPlotX1Y1 = false; % Option to plot dynamics

% Preallocate results
L_YX_mean = zeros(size(couplingX_values));
L_XY_mean = zeros(size(couplingX_values));
R_mean = zeros(size(couplingX_values));
G_mean = zeros(size(couplingX_values));
S_mean = zeros(size(couplingX_values));

R_errors = zeros(size(couplingX_values));
L_XY_errors = zeros(size(couplingX_values));
delta_L_errors = zeros(size(couplingX_values));
L_YX_errors = zeros(size(couplingX_values));
G_errors = zeros(size(couplingX_values));
S_errors = zeros(size(couplingX_values));

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
        [y_aux, ty_aux] = downsampleRosslerSignal(res1(3,:), res1(4,:), false);

        datarec = [x; y]';

        % Compute L metric
        Lmetric = computeLMetric(datarec, 1);

        logger(sprintf("Ex = %f, run = %d, metric L computed = %f", couplingX, runIdx, Lmetric(1)));

        L_XY_runs(runIdx) = Lmetric(1); % L(X|Y)
        L_YX_runs(runIdx) = Lmetric(2); % L(Y|X)

        G_runs(runIdx) = computeGMetric(y, y_aux);
        % logger(sprintf("Ex = %f, run = %d, G(delta)=%f", couplingX, runIdx, mean(G_runs(runIdx))));

        S_runs(runIdx) = computeSMetric(x,y);
        % logger(sprintf("Ex = %f, run = %d, S(phase diff)=%f", couplingX, runIdx, S_runs(runIdx)));

        % Compute R metric
        R_runs(runIdx) = computeRMetric(datarec);
        % logger(sprintf("Ex = %f, run = %d, metric R computed", couplingX, runIdx));

    end

    % Compute mean metrics
    L_YX_mean(idx) = mean(L_YX_runs);
    L_XY_mean(idx) = mean(L_XY_runs);
    R_mean(idx) = mean(R_runs);
    G_mean(idx) = mean(G_runs);
    S_mean(idx) = mean(S_runs);

    R_errors(idx) = std(R_runs) ; 
    L_XY_errors(idx) = std(R_runs) ; 
    L_YX_errors(idx) = std(R_runs) ; 
    G_errors(idx) = std(G_runs) ; 
    S_errors(idx) = std(S_runs) ; 

    delta_L_errors(idx) = std(L_XY_runs-L_YX_runs);

    % Store all runs for plotting
    L_XY_all(idx, :) = L_XY_runs;
    L_YX_all(idx, :) = L_YX_runs;
    R_all(idx, :) = R_runs;
    G_all(idx,:) = G_runs;
    S_all(idx,:) = S_runs;
end
toc

%% Plot results
% plotCoupling(R_mean,R_errors, L_XY_mean, L_XY_errors,L_YX_mean, L_YX_errors, couplingX_values);
% plotCouplingOneMeasure(L_XY_mean,L_XY_errors, 'delta L', couplingX_values);
% plotCouplingOneMeasure(G_mean,G_errors, 'G', couplingX_values);

% plotMetricResults(couplingX_values, L_XY_all, L_XY_mean, 'L_{XY}');
% plotMetricResults(couplingX_values, L_YX_all, L_YX_mean, 'L_{YX}');
% plotMetricResults(couplingX_values, R_all, R_mean, 'R');
% plotMetricResults(couplingX_values, L_XY_all-L_YX_all, L_XY_mean-L_YX_mean, 'delta L')

% figure;
% plot(couplingX_values, G_mean, 'r', ...
%     'LineWidth', 1);
% xlabel('Coupling E_x');
% ylabel('Mean G metric');
% legend('G mean');
% title(sprintf("G metric (generalized sync)"));
% grid on;
% 
% figure;
% semilogy(couplingX_values, G_mean, 'r-o', 'LineWidth', 1);
% xlabel('Coupling E_x');
% ylabel("Mean metric");
% title(sprintf("Mean delta between Y and Y\'"));
% grid on;

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
    % Compute G metric based on the difference between y and y_aux
    G = mean(abs(y-y_aux));
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