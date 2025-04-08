%% Parameters for noisy Rossler
Ey=0;
% Natural frequencies
wx = 1.1;
wy = 0.9;

couplingX_values = [0, logspace(log10(0.01), log10(1), 20)]; % Coupling strengths

numRuns = 20; % Number of runs for averaging
isPlotX1Y1 = false; % Option to plot dynamics

% Preallocate results
L_YX_mean = zeros(size(couplingX_values));
L_XY_mean = zeros(size(couplingX_values));
R_mean = zeros(size(couplingX_values));

R_errors = zeros(size(couplingX_values));
L_XY_errors = zeros(size(couplingX_values));
L_YX_errors = zeros(size(couplingX_values));

noise_levels_SNR = {...
    {0, "NO NOISE"}, ...
    {10, ""}, ...
    {2, ""}, ...
    {1, ""}, ...
    {0.5, ""}, ...
    {0.1, ""}, ...
    {0, "NOISE ONLY"} ...
    };

L_YX_noisy_coupling_mean = zeros(length(noise_levels_SNR), length(couplingX_values));
L_XY_noisy_coupling_mean = zeros(length(noise_levels_SNR), length(couplingX_values));
R_noisy_coupling_mean = zeros(length(noise_levels_SNR), length(couplingX_values));

L_YX_noisy_errors = zeros(length(noise_levels_SNR), length(couplingX_values));
L_XY_noisy_errors = zeros(length(noise_levels_SNR), length(couplingX_values));
R_noisy_errors = zeros(length(noise_levels_SNR), length(couplingX_values));

% %% plot signal versus noisy signal
% for index = 2
%     noise_case = noise_levels_SNR{index}{2};
%     noise_level = noise_levels_SNR{index}{1};
%     res = simulateRossler(0.12, Ey, wx, wy);
%
%     % Downsample and take only the last half
%     [x_original, tx] = downsampleRosslerSignal(res(1,:), res(4,:), false);
%     x_noisy = add_measurement_noise(noise_case, x_original, noise_level);
%
%     plot_x1_vs_noisy_x1(x_original, x_noisy, tx, sprintf("SNR = %d", noise_level),noise_level);
% end

%% Main loop over coupling strengths
for index = 1:length(noise_levels_SNR)
    noise_level = noise_levels_SNR{index}{1};
    noise_case = noise_levels_SNR{index}{2};

    for idx = 1:length(couplingX_values)
        couplingX = couplingX_values(idx);

        L_YX_runs = zeros(numRuns, 1);
        L_XY_runs = zeros(numRuns, 1);
        R_runs = zeros(numRuns, 1);

        for runIdx = 1:numRuns
            % Simulate Rossler systems
            res = simulateRossler(couplingX, Ey, wx, wy);

            % Downsample and take only the last half
            [x_original, tx] = downsampleRosslerSignal(res(1,:), res(4,:), false);
            [y_original, ty] = downsampleRosslerSignal(res(2,:), res(4,:), false);

            [y_original_aux, ty_aux] = downsampleRosslerSignal(res(3,:), res(4,:), false);

            x_noisy = add_measurement_noise(noise_case, x_original, noise_level);
            y_noisy = add_measurement_noise(noise_case, y_original, noise_level);
            y_aux_noisy = add_measurement_noise(noise_case, y_original_aux, noise_level);

            % 
            % figure;
            % plot(tx, x_original, 'b', tx, x_noisy, 'r');
            % ylabel('Values');
            % xlim([tx(1), tx(250)])
            % xlabel('Time [a.u.]');
            % set(gcf,'position',[0,0,600,200])
            % lgd = legend('x_1', 'x_1 (noisy)', 'AutoUpdate', 'off', 'Location', 'northeastoutside');
            % 
            datarec = [x_noisy; y_noisy]';

            % Compute L metric, 1 means no downsampling
            Lmetric = computeLMetric(datarec, 1);

            L_XY_runs(runIdx) = Lmetric(1); % L(X|Y)
            L_YX_runs(runIdx) = Lmetric(2); % L(Y|X)

            % Compute R metric
            R_runs(runIdx) = computeRMetric(datarec);
        end

        % Compute mean metrics
        L_YX_mean(idx) = mean(L_YX_runs);
        L_XY_mean(idx) = mean(L_XY_runs);
        R_mean(idx) = mean(R_runs);

        R_errors(idx) = std(R_runs);
        L_XY_errors(idx) = std(L_XY_runs);
        L_YX_errors(idx) = std(L_YX_runs);

        logger(sprintf("mean metric computed for E_x = %f, SNR = %d", couplingX, noise_level))
    end

    L_XY_noisy_coupling_mean(index,:) = L_XY_mean;
    L_YX_noisy_coupling_mean(index,:) = L_YX_mean;
    R_noisy_coupling_mean(index,:) = R_mean;

    R_noisy_errors(index, :) = R_errors;
    L_XY_noisy_errors(index, :) = L_XY_errors;
    L_YX_noisy_errors(index, :) = L_YX_errors;

    logger(sprintf("mean metric computed for SNR = %d", noise_level))
end

%% Plot results

plotNoisyCoupling(R_noisy_coupling_mean,R_noisy_errors, couplingX_values, noise_levels_SNR, 'R');
plotNoisyCoupling(L_XY_noisy_coupling_mean,L_XY_noisy_errors, couplingX_values, noise_levels_SNR, 'L_{XY}');
plotNoisyCoupling(L_YX_noisy_coupling_mean,L_YX_noisy_errors, couplingX_values, noise_levels_SNR, 'L_{YX}');

% plotNoisyCoupling(L_YX_noisy_coupling_mean,L_YX_noisy_errors, couplingX_values, noise_levels_SNR, 'L_{YX}', '');
% plotNoisyCoupling(G_noisy_coupling_mean, couplingX_values, noise_levels_SNR, 'G', '');
% plotNoisyCoupling(S_noisy_coupling_mean, couplingX_values, noise_levels_SNR, 'S', '');

% save("noisy_rossler.mat",'R_noisy_coupling_mean', 'L_XY_noisy_coupling_mean','L_YX_noisy_coupling_mean', ...
%     'S_noisy_coupling_mean', 'G_noisy_coupling_mean', 'couplingX_values', 'noise_levels_SNR' );


% % Plotting colormap de deltaL
% figure;
% imagesc(1:size(L_XY_noisy_coupling_mean, 2), 1:size(L_XY_noisy_coupling_mean, 1), L_XY_noisy_coupling_mean-L_YX_noisy_coupling_mean);
% colorbar;  % Adds a color bar to indicate the scale
% xlabel('Coupling Strength');
% ylabel('Noise Level');
% title('Mean L(X|Y)-L(Y|X) Metric Values for Noise vs. Coupling Strength');
%
% % Setting the x-ticks and y-ticks
% xticks(1:length(couplingX_values));  % Set x-ticks at each column index
% xticklabels(arrayfun(@(x) sprintf('%.2f', x), couplingX_values, 'UniformOutput', false));  % Label each x-tick with corresponding coupling strength
%
% yticks(1:length(noise_levels_SNR));  % Set y-ticks at each row index
% yticklabels(arrayfun(@(x) num2str(x), noise_levels_SNR, 'UniformOutput', false));  % Label each y-tick with corresponding noise level
%
% % Plotting colormap L(X|Y)
% figure;
% imagesc(1:size(L_XY_noisy_coupling_mean, 2), 1:size(L_XY_noisy_coupling_mean, 1), L_XY_noisy_coupling_mean);
% colorbar;  % Adds a color bar to indicate the scale
% xlabel('Coupling Strength');
% ylabel('Noise Level');
% title('Mean L(X|Y) Metric Values for Noise vs. Coupling Strength');
%
% % Setting the x-ticks and y-ticks
% xticks(1:length(couplingX_values));  % Set x-ticks at each column index
% xticklabels(arrayfun(@(x) sprintf('%.2f', x), couplingX_values, 'UniformOutput', false));  % Label each x-tick with corresponding coupling strength
%
% yticks(1:length(noise_levels_SNR));  % Set y-ticks at each row index
% yticklabels(arrayfun(@(x) num2str(x), noise_levels_SNR, 'UniformOutput', false));  % Label each y-tick with corresponding noise level
%

% % Plotting colormap L(Y|X)
% figure;
% imagesc(1:size(L_YX_noisy_coupling_mean, 2), 1:size(L_YX_noisy_coupling_mean, 1), L_YX_noisy_coupling_mean);
% colorbar;  % Adds a color bar to indicate the scale
% xlabel('Coupling Strength');
% ylabel('Noise Level');
% title('Mean L(Y|X) Metric Values for Noise vs. Coupling Strength');
%
% % Setting the x-ticks and y-ticks
% xticks(1:length(couplingX_values));  % Set x-ticks at each column index
% xticklabels(arrayfun(@(x) sprintf('%.2f', x), couplingX_values, 'UniformOutput', false));  % Label each x-tick with corresponding coupling strength
%
% yticks(1:length(noise_levels_SNR));  % Set y-ticks at each row index
% yticklabels(arrayfun(@(x) num2str(x), noise_levels_SNR, 'UniformOutput', false));  % Label each y-tick with corresponding noise level

% %  R
% figure;
% imagesc(1:size(R_noisy_coupling_mean, 2), 1:size(R_noisy_coupling_mean, 1), R_noisy_coupling_mean);
% colorbar;  % Adds a color bar to indicate the scale
% xlabel('Coupling Strength');
% ylabel('Noise Level');
% title('Mean R Metric Values for Noise vs. Coupling Strength');
%
% % Setting the x-ticks and y-ticks
% xticks(1:length(couplingX_values));  % Set x-ticks at each column index
% xticklabels(arrayfun(@(x) sprintf('%.2f', x), couplingX_values, 'UniformOutput', false));  % Label each x-tick with corresponding coupling strength
%
% yticks(1:length(noise_levels_SNR));  % Set y-ticks at each row index
% yticklabels(arrayfun(@(x) num2str(x), noise_levels_SNR, 'UniformOutput', false));  % Label each y-tick with corresponding noise level


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
end


%% Plot x1 vs noisy_x1
function plot_x1_vs_noisy_x1(x_res, y_res, t, titlePlot, snr)
f=figure;
% t, x_res, 'b', ...
plot( t(end-200:end), x_res(end-200:end), 'b', ...
    t(end-200:end), y_res(end-200:end), 'r' ...
    ); % 'b' и 'r' задают цвета кривых
xlabel('Time [a.u.]');
ylabel('Values');
xlim([t(end-200), t(end)]);
legend('x_1', 'noisy x_1', 'Location','eastoutside');
title(sprintf('Rossler: x_1 and noisy x_1, %s', titlePlot));
grid on;

saveas(f,sprintf("figures/noisy rossler figures/x_vs_x_noisy_SNR_%.1f.jpg", snr));

end