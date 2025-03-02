function plotNoisyCoupling(data, couplingX_values, noise_levels_SNR, metricName, figTitle)
% plotNoisyCoupling - функция для построения графиков зависимости по разным SNR.
%
% Параметры:
%   data             - матрица данных (каждая строка соответствует определенному SNR, ожидается 7 строк)
%   couplingX_values - вектор значений для оси X
%   noise_levels_SNR - cell массив из 7 элементов, где каждый элемент — 1x2 cell array:
%                      {SNR_value, label}, например: {0, "NO_NOISE"}, {10, ""}, ...
%   metricName       - строка с названием метрики (например, 'R', 'L_{XY}', 'L_{YX}', 'G', 'S')
%   figTitle         - заголовок графика
%
% Пример использования:
%   plotNoisyCoupling(R_noisy_coupling_mean, couplingX_values, noise_levels_SNR, 'R', 'Зависимость R от Coupling E_x');

    % Определяем 7 цветов как cell массив с hex кодами
    colors = {'#0072BD', '#D95319', '#EDB120', '#7E2F8E', '#77AC30', '#4DBEEE', '#A2142F'};
    
    f = figure;
    ax = axes('Parent',f);  % создание объекта осей
    hold on;
    
    % Строим графики, назначая каждой линии DisplayName
    for i = 1:7
        label = chooseLabel(noise_levels_SNR{i}, metricName);
        plot(couplingX_values, data(i,:), 'Color', colors{i}, 'LineWidth', 1, 'DisplayName', label);
    end
    
    hold off;
    
    % Легенда автоматически возьмёт имена из DisplayName
    legend('Location', 'eastoutside');
    
    xlabel('Coupling E_x');
    ylabel(metricName);
    title(figTitle);
    grid on;
    
    % Настройка положения осей (при необходимости корректируйте значения)
    set(ax, 'Position', [0.1, 0.1, 0.65, 0.85]);

    savefig(f,sprintf("figures/noisy rossler figures/%s_mean_for_SNR.fig", metricName));
    saveas(f,sprintf("figures/noisy rossler figures/%s_mean_for_SNR.jpg", metricName));
end

function label = chooseLabel(c, metricName)
    % Формирует метку для легенды.
    % Если второй элемент не пустой, используется он; иначе используется SNR.
    if ~strcmp(c{2}, "")
        label = sprintf('%s, %s', metricName, c{2});
    else
        label = sprintf('%s, SNR = %.1f', metricName, c{1});
    end
end
