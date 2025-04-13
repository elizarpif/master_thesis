function plotScatterZonas(L_selected, R_selected, selectedPairNames, ...
    timePointNames,  ...
    filename, figurename)

num_pairs = size(L_selected, 1);
num_times = size(L_selected, 2);

L_vec = reshape(L_selected', [], 1);
R_vec = reshape(R_selected', [], 1);

f = figure;
hold on;

scatter(L_vec, R_vec, 20, 'b', 'filled');

% indices start and end
timeSeizureStart = 9; 
timeSeizureEnd = length(timePointNames)-8;

scatter_handles = repmat(struct('scatter', [], 'pair', '', 'timeIdx', 0), num_pairs * num_times, 1);

idx = 1;
% colorBefore = 'g';
% colorSeizure = 'r';
% colorAfter = 'b';

for i = 1:num_pairs
    for j = 1:num_times
        L_val = L_selected(i, j);
        R_val = R_selected(i, j);

        color = 'r';
        if j < timeSeizureStart
            color = 'g';
        end
        if j > timeSeizureEnd
            color = 'b';
        end

        % Plot the point
        h_scatter = scatter(L_val, R_val, 36, color, 'filled');

        scatter_handles(idx).scatter = h_scatter;
        scatter_handles(idx).pair = selectedPairNames{i};
        scatter_handles(idx).timeIdx = j;

        idx = idx + 1;
    end
end
hold off;


% % plot the red dot
% for pair_idx = 1:num_pairs
%     if wantPair == selectedPairNames(pair_idx)
%         for time_idx = 1:num_times
%             if wantTimeIntervalEnd == timePointNames(time_idx) || wantTimeIntervalEnd == ""
%                 h_red = scatter(L_selected(pair_idx, time_idx), R_selected(pair_idx, time_idx), 30, 'r', 'o', 'filled');
%                 scatter_struct = struct('scatter', h_red, 'pair', selectedPairNames(pair_idx), 'timeIdx', time_idx);
% 
%                 % not the best way, but it is a quick decision
%                 scatter_handles{pair_idx} = [scatter_handles{pair_idx}, scatter_struct];
%             end
%         end
%     end
% end

xlabel('Metric L');
ylabel('Metric R');
title(sprintf("Scatter Plot L vs R (%s)", figurename));
grid on;
% legend(selectedPairNames, 'Location', 'eastoutside');
hold off;


% Подключаем Data Cursor
dcm = datacursormode(gcf);
set(dcm, 'UpdateFcn', @(obj, event_obj) displayPointInfo(event_obj, scatter_handles));

if filename ~= ""
    saveas(f, filename);
end

end

function output_txt = displayPointInfo(event_obj, scatter_handles)
selected_scatter = [];

for i = 1:length(scatter_handles)
    if scatter_handles(i).scatter == event_obj.Target
        selected_scatter = scatter_handles(i);
    end
end

time_idx = selected_scatter.timeIdx;
pair = mselected_scatter.pair;

% logger("pair %d time idx %d pos %f %f", pair_idx, time_idx, pos(1), pos(2));
if ~isempty(time_idx)
    output_txt = {sprintf('Pair: %s', pair), ...
        sprintf('Time interval: %d-%d s', time_idx*20-20, time_idx*20)};
    logger(sprintf("%s, time interval %d-%d s", pair, time_idx*20-20, time_idx*20));
else
    output_txt = {'No data found'};
end
end


