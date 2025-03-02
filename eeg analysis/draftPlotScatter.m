load('pat16_part1_results.mat');


% % % %

% remove last 3 seconds result
L_XY_all = L_XY_all(:,:,1:end-1);
R_all = R_all(:,:,1:end-1);
timePointNames = timePointNames(1:end-1);

L_XY_all_alpha = squeeze(L_XY_all(1, :, :));
R_all_alpha = squeeze(R_all(1, :, :));

colorbarMin = min([min(L_XY_all_alpha(:)), min(R_all_alpha(:))]);
colorbarMax = max([max(L_XY_all_alpha(:)), max(R_all_alpha(:))]);

eegImagescResultMask(timePointNames, L_XY_all_alpha, numPairs, ...
    percentEndSeizureLocation, sprintf("L_{XY} (%s)", bands(1)), ...
    selectedPairNames, differenceMask, colorbarMin, colorbarMax);
eegImagescResultMask(timePointNames, R_all_alpha, numPairs, ...
    percentEndSeizureLocation, sprintf("R (%s)", bands(2)), ...
    selectedPairNames, differenceMask, colorbarMin, colorbarMax)

% 

bands = ["alpha", "beta", "theta", "delta"];
selected_band = 2; % Select the frequency band (1: alpha, 2: beta, 3: theta, 4: delta)

L_selected = squeeze(L_XY_all(selected_band, :, :));
R_selected = squeeze(R_all(selected_band, :, :));

num_pairs = size(L_selected, 1);
num_times = size(L_selected, 2);

figure;
hold on;
colors = lines(num_pairs);
scatter_handles = gobjects(num_pairs, 1); % сохраним scatter-объекты

for pair_idx = 1:num_pairs
    scatter_handles(pair_idx) = scatter(L_selected(pair_idx, :), R_selected(pair_idx, :),...
        20, colors(pair_idx, :), 'filled');
end

xlabel('Metric L');
ylabel('Metric R');
title('Scatter Plot L vs R');
grid on;
legend(selectedPairNames, 'Location', 'eastoutside');
hold off;

% Подключаем Data Cursor
dcm = datacursormode(gcf);
set(dcm, 'UpdateFcn', @(obj, event_obj) displayPointInfo(event_obj, scatter_handles, selectedPairNames, timePointNames));

function output_txt = displayPointInfo(event_obj, scatter_handles, selectedPairNames, timePointNames)
    pair_idx = find(scatter_handles == event_obj.Target, 1);
    time_idx = event_obj.DataIndex;
    
    % logger("pair %d time idx %d pos %f %f", pair_idx, time_idx, pos(1), pos(2));
    if ~isempty(pair_idx) && ~isempty(time_idx)
        output_txt = {sprintf('Pair: %s', selectedPairNames{pair_idx}), ...
                      sprintf('Time interval: %d', time_idx*20-20)};
        logger(sprintf("%s, time interval %d-%d s", selectedPairNames{pair_idx}, time_idx*20-20, time_idx*20));
    else
        output_txt = {'No data found'};
    end
end