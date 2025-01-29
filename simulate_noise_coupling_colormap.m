% Define the coupling strengths for demonstration. Replace with your actual data.
couplingX_values = linspace(0, 1, 31);  % example values

% Assuming L_YX_noisy_coupling_mean is filled with your computed mean values
% You can uncomment the next line to simulate some data
% L_YX_noisy_coupling_mean = rand(6, length(couplingX_values));  % Simulated data

% Plotting
figure;
imagesc(couplingX_values, 1:5, L_YX_noisy_coupling_mean);
colorbar;  % Adds a color bar to indicate the scale
xlabel('Coupling Strength');
ylabel('Noise Level');
title('Mean Metric Values for Noise vs. Coupling Strength');

% Optional: Set custom colormap
% colormap(jet);  % You can change 'jet' to any other colormap (e.g., 'hot', 'cool', 'parula')

% Improving the axes
xticks(couplingX_values);  % Set x-ticks to match the coupling values
yticks(1:5);  % Noise levels are already correctly set, but this ensures clarity
