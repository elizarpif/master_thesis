function plotNoisyCoupling(data,errors, couplingX_values, noise_levels_SNR, metricName, figTitle)
% plotNoisyCoupling - функция для построения графиков зависимости по разным SNR в логарифмическом масштабе X.
%
% Параметры:
%   data             - матрица данных (каждая строка соответствует определенному SNR, ожидается 7 строк)
%   couplingX_values - вектор значений для оси X (созданный с помощью logspace)
%   noise_levels_SNR - cell массив из 7 элементов, где каждый элемент — 1x2 cell array:
%                      {SNR_value, label}, например: {0, "NO_NOISE"}, {10, ""}, ...
%   metricName       - строка с названием метрики (например, 'R', 'L_{XY}', 'L_{YX}', 'G', 'S')
%   figTitle         - заголовок графика

    colors = {'#0072BD', '#D95319', '#EDB120', '#7E2F8E', '#77AC30', '#4DBEEE', '#A2142F'};
    
    f = figure;
    ax = axes('Parent',f);
    hold on;
    
    for i = 1:7
        label = chooseLabel(noise_levels_SNR{i}, metricName);

        % Plot line with error bars
        errorbar(couplingX_values, data(i,:), errors(i,:), ...
            'Color', colors{i}, ...
            'LineWidth', 1, ...
            'DisplayName', label, ...
            'CapSize', 3);

        % semilogx(couplingX_values, data(i,:), 'Color', colors{i}, 'LineWidth', 1, 'DisplayName', label);
    end
    
    hold off;
    
    legend('Location', 'eastoutside');
    xlabel('Coupling E_x (log scale)');
    ylabel(metricName);
    title(figTitle);
    grid on;

    set(ax, 'Position', [0.1, 0.1, 0.65, 0.85]);

    set(gca, 'XScale', 'log');
    savefig(f,sprintf("figures/noisy rossler figures/%s_mean_for_SNR.fig", metricName));
    saveas(f,sprintf("figures/noisy rossler figures/%s_mean_for_SNR.jpg", metricName));
end

function label = chooseLabel(c, metricName)
    if ~strcmp(c{2}, "")
        label = sprintf('%s, %s', metricName, c{2});
    else
        label = sprintf('%s, SNR = %.1f', metricName, c{1});
    end
end
