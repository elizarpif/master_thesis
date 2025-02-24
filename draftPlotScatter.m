% load('pat16_part1_results.mat');


% % % %

% remove last 3 seconds result
% L_XY_all = L_XY_all(:,:,1:end-1);
% R_all = R_all(:,:,1:end-1);
% timePointNames = timePointNames(1:end-1);

bands = ["alpha", "beta", "theta", "delta"];
selected_band = 3; % Select the frequency band (1: alpha, 2: beta, 3: theta, 4: delta)


[~, pairCount, timeCount] = size(L_XY_all);

% Extract the data for the selected band
L_selected = squeeze(L_XY_all(selected_band, :, :));  % Shape: (pairCount, timeCount)
R_selected = squeeze(R_all(selected_band, :, :));  % Shape: (pairCount, timeCount)

% Create scatter plot with individual pairs
figure;
hold on;
colors = lines(pairCount); % Generate distinct colors

for pair_idx = 1:pairCount
    scatter(L_selected(pair_idx, :), R_selected(pair_idx, :), 20, colors(pair_idx, :), 'filled');
end

xlabel('Metric L');
ylabel('Metric R');
title(sprintf('Scatter Plot of Metric L vs Metric R (Band %s)', bands(selected_band)));
grid on;
legend_labels = arrayfun(@(x) selectedPairNames(x), 1:pairCount, 'UniformOutput', false);
legend(legend_labels, 'Location', 'eastoutside'); % Move legend outside


hold off;


dcm = datacursormode(gcf);
set(dcm, 'UpdateFcn', @(obj, event_obj) displayPointInfo(event_obj, L_selected, R_selected, selectedPairNames,timePointNames));

% Custom function to display pair and time when clicking on a point
function output_txt = displayPointInfo(event_obj, ...
    L_selected, R_selected, selectedPairNames, timePointNames)
    pos = get(event_obj, 'Position'); % Get (L, R) position

    % Find the closest matching (L, R) point in the dataset
    [pair_idx, time_idx] = find(L_selected == pos(1) & R_selected == pos(2), 1);
    
    if ~isempty(pair_idx)
        output_txt = {sprintf('Pair: %s', selectedPairNames(pair_idx)), sprintf('Time interval: %s', timePointNames(time_idx))};
    else
        output_txt = {'No data found'};
    end
end


% Find the index of the outlier (manually identified from the plot)
outlier_idx = 14; % Change this based on what you clicked
timeIdx = 16;
fprintf('Pair: %s, Time interval: %d\n', selectedPairNames{outlier_idx}, timeIdx);
fprintf('L = %.4f, R = %.4f\n', L_selected(outlier_idx, timeIdx), R_selected(outlier_idx, timeIdx));
