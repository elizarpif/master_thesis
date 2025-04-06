function plotScatter(L_selected, R_selected, selectedPairNames, ...
    timePointNames, wantPair, wantTimeIntervalEnd, paintSeizureParts, ...
    filename, figurename)

num_pairs = size(L_selected, 1);
num_times = size(L_selected, 2);

f = figure;
hold on;

scatter_handles = cell(num_pairs, 1); % Use a cell array to store one or more scatter handles per pair

for pair_idx = 1:num_pairs
    h_scatter = scatter(L_selected(pair_idx, :), R_selected(pair_idx, :), 20, 'b', 'filled');

    % Create a struct with two fields: scatter (the handle) and label (a string)
    scatter_struct = struct('scatter', h_scatter, 'pair', selectedPairNames{pair_idx}, 'timeIdx', 0);

    % Store the struct in the cell array
    scatter_handles{pair_idx} = scatter_struct;
end

if paintSeizureParts
    timeSeizureStart = 9;
    timeSeizureEnd = 13;

    for pair_idx = 1:num_pairs
        for time_idx = 1:num_times
            color = 'r';
            if time_idx < timeSeizureStart
                color = 'g';
            end
            if time_idx > timeSeizureEnd
                color = 'b';
            end
            h_red = scatter(L_selected(pair_idx, time_idx), R_selected(pair_idx, time_idx), 20, color, 'o', 'filled');
            scatter_struct = struct('scatter', h_red, 'pair', selectedPairNames(pair_idx), 'timeIdx', time_idx);

            % not the best way, but it is a quick decision
            scatter_handles{pair_idx} = [scatter_handles{pair_idx}, scatter_struct];
        end
    end

end

% plot the red dot
for pair_idx = 1:num_pairs
    if wantPair == selectedPairNames(pair_idx)
        for time_idx = 1:num_times
            if wantTimeIntervalEnd == timePointNames(time_idx) || wantTimeIntervalEnd == ""
                h_red = scatter(L_selected(pair_idx, time_idx), R_selected(pair_idx, time_idx), 30, 'r', 'o', 'filled');
                scatter_struct = struct('scatter', h_red, 'pair', selectedPairNames(pair_idx), 'timeIdx', time_idx);

                % not the best way, but it is a quick decision
                scatter_handles{pair_idx} = [scatter_handles{pair_idx}, scatter_struct];
            end
        end
    end
end

xlabel('Metric L');
ylabel('Metric R');
title(sprintf("Scatter Plot L vs R (%s)", figurename));
grid on;
% legend(selectedPairNames, 'Location', 'eastoutside');
hold off;


% Подключаем Data Cursor
dcm = datacursormode(gcf);
set(dcm, 'UpdateFcn', @(obj, event_obj) displayPointInfo(event_obj, scatter_handles, selectedPairNames));

if filename ~= ""
    saveas(f, filename);
end

end

function output_txt = displayPointInfo(event_obj, scatter_handles, selectedPairNames)
pair_idx = [];
disp(event_obj.DataIndex);
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


