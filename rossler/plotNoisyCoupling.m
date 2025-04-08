function plotNoisyCoupling(data, errors, couplingX_values, noise_levels_SNR, metricName)
    colors = {'#0072BD', '#D95319', '#EDB120', '#7E2F8E', '#77AC30', '#4DBEEE', '#A2142F'};
    f = figure;
    zero_idx = couplingX_values == 0;
    nonzero_idx = couplingX_values ~= 0;

    ax2 = axes('Position', [0.1, 0.1, 0.05, 0.85]);
    hold(ax2, 'on');
    dummyX = zeros(sum(zero_idx), 1);
    for i = 1:7
        label = chooseLabel(noise_levels_SNR{i}, metricName);
        errorbar(ax2, dummyX, data(i, zero_idx), errors(i, zero_idx), ...
            'Color', colors{i}, 'LineWidth', 1, 'DisplayName', label, 'CapSize', 3);
    end
    hold(ax2, 'off');
    ylabel(ax2, metricName);
    grid(ax2, 'on');
    ylim(ax2, [-0.2, 1]);
    set(ax2, 'XTick', 0, 'XTickLabel', {'0'});

    ax1 = axes('Position', [0.17, 0.1, 0.8, 0.85]);
    hold(ax1, 'on');
    for i = 1:7
        label = chooseLabel(noise_levels_SNR{i}, metricName);
        errorbar(ax1, couplingX_values(nonzero_idx), data(i, nonzero_idx), errors(i, nonzero_idx), ...
            'Color', colors{i}, 'LineWidth', 1, 'DisplayName', label, 'CapSize', 3);
    end
    hold(ax1, 'off');
    legend(ax1, 'Location', 'eastoutside');
    xlabel(ax1, 'Coupling E_x (log scale)');
    grid(ax1, 'on');
    set(ax1, 'XScale', 'log');
    set(ax1, 'YTickLabel', []);
    ylim(ax1, [-0.2, 1]);

    savefig(f, sprintf("figures/noisy rossler figures/%s_mean_for_SNR.fig", metricName));
    saveas(f, sprintf("figures/noisy rossler figures/%s_mean_for_SNR.jpg", metricName));
end

function label = chooseLabel(c, metricName)
    if ~strcmp(c{2}, "")
        label = sprintf('%s, %s', metricName, c{2});
    else
        label = sprintf('%s, SNR = %.1f', metricName, c{1});
    end
end
