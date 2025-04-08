function plotCoupling(R, R_errors, L_XY, L_XY_errors, L_YX, L_YX_errors, couplingX_values)
    f = figure;
    zero_idx = couplingX_values == 0;
    nonzero_idx = ~zero_idx;

    ax2 = axes('Position', [0.1, 0.1, 0.05, 0.85]);
    hold(ax2, 'on');
    dummyX = zeros(sum(zero_idx), 1);
    errorbar(ax2, dummyX, R(zero_idx), R_errors(zero_idx), 'Color', '#0072BD', 'LineWidth', 1, 'DisplayName', 'R', 'CapSize', 5);
    errorbar(ax2, dummyX, L_XY(zero_idx), L_XY_errors(zero_idx), 'Color', '#D95319', 'LineWidth', 1, 'DisplayName', 'L(X|Y)', 'CapSize', 5);
    errorbar(ax2, dummyX, L_YX(zero_idx), L_YX_errors(zero_idx), 'Color', '#EDB120', 'LineWidth', 1, 'DisplayName', 'L(Y|X)', 'CapSize', 5);
    
    plot(ax2, dummyX, R(zero_idx), ...
        'o', 'MarkerSize', 3, 'MarkerFaceColor', '#0072BD', 'Color', '#0072BD','HandleVisibility', 'off')
    plot(ax2, dummyX, L_XY(zero_idx), ...
        'o', 'MarkerSize', 3, 'MarkerFaceColor', '#D95319', 'Color', '#D95319','HandleVisibility', 'off');
    plot(ax2, dummyX, L_YX(zero_idx), ...
        'o', 'MarkerSize', 3, 'MarkerFaceColor', '#EDB120','Color', '#EDB120','HandleVisibility', 'off');

    hold(ax2, 'off');
    ylabel(ax2, 'Value');
    grid(ax2, 'on');
    ylim(ax2, [-0.2, 1.2]);
    set(ax2, 'XTick', 0, 'XTickLabel', {'0'});

    ax1 = axes('Position', [0.17, 0.1, 0.8, 0.85]);
    hold(ax1, 'on');
    errorbar(ax1, couplingX_values(nonzero_idx), R(nonzero_idx), R_errors(nonzero_idx), ...
        'Color', '#0072BD', 'LineWidth', 1, 'DisplayName', 'R', 'CapSize', 5);
    errorbar(ax1, couplingX_values(nonzero_idx), L_XY(nonzero_idx), L_XY_errors(nonzero_idx), ...
        'Color', '#D95319', 'LineWidth', 1, 'DisplayName', 'L(X|Y)', 'CapSize', 5);
    errorbar(ax1, couplingX_values(nonzero_idx), L_YX(nonzero_idx), L_YX_errors(nonzero_idx), ...
        'Color', '#EDB120', 'LineWidth', 1, 'DisplayName', 'L(Y|X)', 'CapSize', 5);
    
    plot(ax1, couplingX_values(nonzero_idx), R(nonzero_idx), ...
        'o', 'MarkerSize', 3, 'MarkerFaceColor', '#0072BD', 'Color', '#0072BD','HandleVisibility', 'off')
    plot(ax1, couplingX_values(nonzero_idx), L_XY(nonzero_idx), ...
        'o', 'MarkerSize', 3, 'MarkerFaceColor', '#D95319', 'Color', '#D95319','HandleVisibility', 'off');
    plot(ax1, couplingX_values(nonzero_idx), L_YX(nonzero_idx), ...
        'o', 'MarkerSize', 3, 'MarkerFaceColor', '#EDB120','Color', '#EDB120','HandleVisibility', 'off');

    hold(ax1, 'off');
    legend(ax1, 'Location', 'eastoutside');
    xlabel(ax1, 'Coupling E_x');
    xticks(ax1, [0.01 0.02 0.05 0.1 0.2 0.5 1]);
    set(ax1, 'YTickLabel', []);
    grid(ax1, 'on');
    set(ax1, 'XScale', 'log');
    ylim(ax1, [-0.2, 1.2]);

    % savefig(f, sprintf("figures/noise free rossler figures/noise_free_results.fig"));
    saveas(f, sprintf("figures/noise free rossler figures/noise_free_results.jpg"));
end
