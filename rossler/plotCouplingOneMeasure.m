function plotCouplingOneMeasure(R, R_errors, measure_name, couplingX_values)
    f = figure;
    zero_idx = couplingX_values == 0;
    nonzero_idx = ~zero_idx;

    ax2 = axes('Position', [0.1, 0.1, 0.05, 0.85]);
    hold(ax2, 'on');
    dummyX = zeros(sum(zero_idx), 1);
    errorbar(ax2, dummyX, R(zero_idx), R_errors(zero_idx), ...
        'Color', '#0072BD', 'LineWidth', 1, 'CapSize', 5);
    % Plot the markers on top with custom attributes
plot(ax2, couplingX_values(zero_idx), R(zero_idx), ...
     'o', 'MarkerSize', 3, 'MarkerFaceColor', '#0072BD', 'Color', '#0072BD');
    hold(ax2, 'off');
    ylabel(ax2, 'Value');
    grid(ax2, 'on');
    ylim(ax2, [min(R)-max(R_errors), max(R)+max(R_errors)]);
    set(ax2, 'XTick', 0, 'XTickLabel', {'0'});

    ax1 = axes('Position', [0.17, 0.1, 0.8, 0.85]);
    hold(ax1, 'on');
    errorbar(ax1, couplingX_values(nonzero_idx), R(nonzero_idx), R_errors(nonzero_idx), ...
        'Color', '#0072BD', 'LineWidth', 1, 'CapSize', 5);
    % Plot the markers on top with custom attributes
    plot(ax1, couplingX_values(nonzero_idx), R(nonzero_idx), ...
     'o', 'MarkerSize', 3, 'MarkerFaceColor', '#0072BD', 'Color', '#0072BD');
    % xline(ax1, 0.1833, 'r--', 'LineWidth', 1.5);
    hold(ax1, 'off');
    % legend(ax1, 'Location', 'eastoutside');
    xlabel(ax1, 'Coupling E_x');
    xticks(ax1, [0.01 0.02 0.05 0.1 0.2 0.5 1]);
    set(ax1, 'YTickLabel', []);
    grid(ax1, 'on');
    set(ax1, 'XScale', 'log');
    ylim(ax1, [min(R)-max(R_errors), max(R)+max(R_errors)]);

    savefig(f, sprintf("figures/noise free rossler figures/%s_results.fig", measure_name));
    saveas(f, sprintf("figures/noise free rossler figures/%s_results.jpg",measure_name));
end
