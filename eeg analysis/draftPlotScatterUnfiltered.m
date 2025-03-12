load('pat16_part1_results_unfiltered.mat');
L_selected = L_XY_unfiltered;
R_selected = R_unfiltered;

wantPair = "TPPR1-TPPR2";
wantTimeIntervalEnd = "220";

plotScatter(L_selected, R_selected, selectedPairNames, timePointNames, wantPair, wantTimeIntervalEnd)

function plotScatter(L_selected, R_selected, selectedPairNames, ...
    timePointNames, wantPair, wantTimeIntervalEnd)

num_pairs = size(L_selected, 1);
num_times = size(L_selected, 2);

figure;
hold on;
% colors = lines(num_pairs);
scatter_handles = cell(num_pairs, 1); % Use a cell array to store one or more scatter handles per pair

for pair_idx = 1:num_pairs
    h_scatter = scatter(L_selected(pair_idx, :), R_selected(pair_idx, :), 20, 'b', 'filled');

    % Create a struct with two fields: scatter (the handle) and label (a string)
    scatter_struct = struct('scatter', h_scatter, 'pair', selectedPairNames{pair_idx}, 'timeIdx', 0);

    % Store the struct in the cell array
    scatter_handles{pair_idx} = scatter_struct;
end

% plot the red dot
for pair_idx = 1:num_pairs
    if wantPair == selectedPairNames(pair_idx)
        if wantTimeIntervalEnd == ""
            h_red = scatter(L_selected(pair_idx, :), R_selected(pair_idx, :), 30, 'r', 'o', 'filled');
            scatter_struct = struct('scatter', h_red, 'pair', selectedPairNames(pair_idx), 'timeIdx', time_idx);

            scatter_handles{pair_idx} = [scatter_handles{pair_idx}, scatter_struct];
        else

            for time_idx = 1:num_times
                if wantTimeIntervalEnd == timePointNames(time_idx)
                    h_red = scatter(L_selected(pair_idx, time_idx), R_selected(pair_idx, time_idx), 30, 'r', 'o', 'filled');
                    scatter_struct = struct('scatter', h_red, 'pair', selectedPairNames(pair_idx), 'timeIdx', time_idx);

                    scatter_handles{pair_idx} = [scatter_handles{pair_idx}, scatter_struct];
                end
            end
        end
    end
end

xlabel('Metric L');
ylabel('Metric R');
title('Scatter Plot L vs R (unfiltered)');
grid on;
legend(selectedPairNames, 'Location', 'eastoutside');
hold off;


% Подключаем Data Cursor
dcm = datacursormode(gcf);
set(dcm, 'UpdateFcn', @(obj, event_obj) displayPointInfo(event_obj, scatter_handles, selectedPairNames));

end

function output_txt = displayPointInfo(event_obj, scatter_handles, selectedPairNames)
pair_idx = [];
% Loop over each cell element to see if event_obj.Target is in that array of handles
for i = 1:length(scatter_handles)
    for j = 1:length(scatter_handles{i})

        if any(scatter_handles{i}(j).scatter == event_obj.Target)

            if scatter_handles{i}(j).timeIdx == 0
                time_idx = event_obj.DataIndex;
            else
                time_idx = scatter_handles{i}(j).timeIdx;
            end

            pair_idx = i;
            break;
        end
    end

end


% logger("pair %d time idx %d pos %f %f", pair_idx, time_idx, pos(1), pos(2));
if ~isempty(pair_idx) && ~isempty(time_idx)
    output_txt = {sprintf('Pair: %s', selectedPairNames{pair_idx}), ...
        sprintf('Time interval: %d-%d s', time_idx*20-20, time_idx*20)};
    logger(sprintf("%s, time interval %d-%d s", selectedPairNames{pair_idx}, time_idx*20-20, time_idx*20));
else
    output_txt = {'No data found'};
end
end


