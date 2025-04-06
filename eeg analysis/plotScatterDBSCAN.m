function plotScatterDBSCAN(L_selected, R_selected, selectedPairNames)

num_pairs = size(L_selected, 1);
num_times = size(L_selected, 2);

% scatter_handles = cell(num_pairs, 1); % Use a cell array to store one or more scatter handles per pair

% need to transpose, because I need row-wise pairing
L_vec = reshape(L_selected', [], 1);
R_vec = reshape(R_selected', [], 1);
X = [L_vec, R_vec];

% Параметры DBSCAN (подберите epsilon и minPts под ваши данные)
epsilon = kmeans(L_vec, 1);
disp(epsilon);
minPts = 5;
% Применяем DBSCAN. Точки с меткой -1 считаются выбросами.
% 704x1
labels = dbscan(X, epsilon, minPts);

num_points = num_pairs * num_times;
% Инициализируем массив структур для хранения данных каждой точки
scatter_handles = repmat(struct('scatter', [], 'pair', '', 'timeIdx', 0, 'dbscanLabel', 0), num_points, 1);

figure;
hold on;
idx = 1;



% Перебираем пары и временные точки для сохранения информации
for pair_idx = 1:num_pairs
    % idx = 1...22, pairname = 1
    % idx = 23..45, pairname = 2
    for time_idx = 1:num_times

        % Получаем метку DBSCAN для текущей точки
        current_label = labels(idx);
        % Если метка -1, это выброс – задаем красный цвет, иначе синий
        if current_label == -1
            point_color = 'r';

            fprintf("Pair: %s, Time interval: %d-%d s\n", selectedPairNames{pair_idx}, time_idx*20-20, time_idx*20);
        else
            point_color = 'b';
        end

        % Рисуем точку индивидуально
        h_scatter = scatter(X(idx, 1), X(idx, 2), 20, point_color, 'filled');

        % Сохраняем информацию о точке в структуру
        scatter_handles(idx).scatter = h_scatter;
        scatter_handles(idx).pair = selectedPairNames{pair_idx};
        scatter_handles(idx).timeIdx = time_idx;
        scatter_handles(idx).dbscanLabel = current_label;

        % logger(sprintf("idx = %d, pairname = %s, time =%d", idx, selectedPairNames{pair_idx}, time_idx))

        idx = idx + 1;

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
set(dcm, 'UpdateFcn', @(obj, event_obj) displayPointInfo(event_obj, scatter_handles));

% saveOutlierData(scatter_handles, outlierFileName);

end

function output_txt = displayPointInfo(event_obj, scatter_handles)
for i = 1:length(scatter_handles)
    if event_obj.Target == scatter_handles(i).scatter
        pairName = scatter_handles(i).pair;
        time_idx  = scatter_handles(i).timeIdx;

        output_txt = {sprintf('Pair: %s', pairName), ...
            sprintf('Time interval: %d-%d s', time_idx*20-20, time_idx*20)};
        logger(sprintf("%s, time interval %d-%d s", pairName, time_idx*20-20, time_idx*20));

        break;
    end
end


end



function epsilon = estimateEpsilonForDBSCANUsingKMeans(X, thresholdFactor)
% estimateEpsilonForDBSCANUsingKMeans estimates an epsilon value for DBSCAN
% by using k-means (with k=1) to compute the centroid and then computing
% the distances from all points to this centroid.
%
%   epsilon = estimateEpsilonForDBSCANUsingKMeans(X, thresholdFactor)
%
%   INPUT:
%     X              - N x d data matrix (each row is an observation)
%     thresholdFactor- (optional) multiplier to set the threshold
%                      Default is 2.
%
%   OUTPUT:
%     epsilon - the estimated epsilon for DBSCAN.
%
% The method computes the centroid, then calculates the Euclidean distances
% from each point to the centroid. The estimated epsilon is:
%    epsilon = mean(distance) + thresholdFactor * std(distance)
%
% Example:
%    X = randn(100,2);
%    epsilon = estimateEpsilonForDBSCANUsingKMeans(X, 2);
%

    if nargin < 2
        thresholdFactor = 2;
    end

    % Run k-means with k=1 to get the overall centroid
    [~, centroid] = kmeans(X, 1, 'Replicates', 10);

    % Compute Euclidean distances from each point to the centroid
    distances = sqrt(sum((X - centroid).^2, 2));

    % Estimate epsilon as mean(distance) plus thresholdFactor times std(distance)
    epsilon = mean(distances) + thresholdFactor * std(distances);

    % Optionally, you might also use a high quantile as an alternative:
    % epsilon = quantile(distances, 0.95);
end
