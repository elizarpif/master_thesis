% load('pat16_part1_results.mat');

[~, pairCount, timeCount] = size(L_XY_unfiltered);

% Extract the data for the selected band
L_selected = L_XY_unfiltered(:,1:end-1);  % Shape: (pairCount, timeCount)
R_selected = R_unfiltered(:,1:end-1);  % Shape: (pairCount, timeCount)

% Create scatter plot with individual pairs
figure;
hold on;
colors = lines(pairCount); % Generate distinct colors

for pair_idx = 1:pairCount
    % 20 - size of a marker
    scatter(L_selected(pair_idx, :), R_selected(pair_idx, :), 20, colors(pair_idx, :), 'filled');
end

xlabel('Metric L');
ylabel('Metric R');
title('Scatter Plot of Metric L vs Metric R (unfiltered)');
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