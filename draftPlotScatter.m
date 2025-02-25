% load('pat16_part1_results.mat');


% % % %

% remove last 3 seconds result
% L_XY_all = L_XY_all(:,:,1:end-1);
% R_all = R_all(:,:,1:end-1);
% timePointNames = timePointNames(1:end-1);

bands = ["alpha", "beta", "theta", "delta"];
selected_band = 3; % Select the frequency band (1: alpha, 2: beta, 3: theta, 4: delta)

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
    
    pos = get(event_obj, 'Position');
    disp(pos(1))
    disp(pair_idx)
    % logger("pair %d time idx %d pos %f %f", pair_idx, time_idx, pos(1), pos(2));
    if ~isempty(pair_idx) && ~isempty(time_idx)
        output_txt = {sprintf('Pair: %s', selectedPairNames{pair_idx}), ...
                      sprintf('Time interval: %s', timePointNames{time_idx})};
    else
        output_txt = {'No data found'};
    end
end