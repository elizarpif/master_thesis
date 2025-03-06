load('pat16_part1_results_unfiltered.mat');

L_selected = L_XY_unfiltered;
R_selected = R_unfiltered;  

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
title('Scatter Plot L vs R (unfiltered)');
grid on;
legend(selectedPairNames, 'Location', 'eastoutside');
hold off;

% Подключаем Data Cursor
dcm = datacursormode(gcf);
set(dcm, 'UpdateFcn', @(obj, event_obj) displayPointInfo(event_obj, scatter_handles, selectedPairNames));

function output_txt = displayPointInfo(event_obj, scatter_handles, selectedPairNames)
    pair_idx = find(scatter_handles == event_obj.Target, 1);
    time_idx = event_obj.DataIndex;

    % logger("pair %d time idx %d pos %f %f", pair_idx, time_idx, pos(1), pos(2));
    if ~isempty(pair_idx) && ~isempty(time_idx)
        output_txt = {sprintf('Pair: %s', selectedPairNames{pair_idx}), ...
                      sprintf('Time interval: %d-%d s', time_idx*20-20, time_idx*20)};
        logger(sprintf("%s, time interval %d-%d s", selectedPairNames{pair_idx}, time_idx*20-20, time_idx*20));
    else
        output_txt = {'No data found'};
    end
end

% % Данные из scatter plot
% X = L_selected(:); % Координаты X
% Y = R_selected(:); % Координаты Y
% 
% % 1. Полиномиальная регрессия (вместо прямой используем параболу)
% degree = 3; % Можно попробовать 3, если изгиб сильный
% coeffs = polyfit(X, Y, degree);
% Y_pred = polyval(coeffs, X); % Вычисляем предсказанные значения
% 
% % 2. Вычисляем остатки (разница между фактическими и предсказанными Y)
% residuals = abs(Y - Y_pred);
% 
% % 3. Определяем выбросы (если остаток выше 4 стандартных отклонений)
% threshold = 4 * std(residuals);
% outliers = residuals > threshold;
% 
% % 4. Визуализация результатов
% figure; hold on;
% scatter(X, Y, 'b', 'filled'); % Обычные точки
% scatter(X(outliers), Y(outliers), 'r', 'filled'); % Выбросы
% plot(sort(X), polyval(coeffs, sort(X)), 'k--', 'LineWidth', 2); % Линия полиномиальной регрессии
% 
% legend('Normal points', 'Outliers', 'Polynomial regression');
% title('Outlier Detection using Polynomial Regression Residuals');
% xlabel('L_selected (X)');
% ylabel('R_selected (Y)');
