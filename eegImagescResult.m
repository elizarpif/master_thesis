function eegImagescResult(timePoints, L_XY_all, numPairs, intervalJump, Fs, metricName, selectedPairNames)
    % Plot metrics with vertical red lines at specific points

    % Create the figure
    figure;
    imagesc(timePoints, 1:numPairs, L_XY_all); % Set timePoints as X-axis
    colorbar;
    title(sprintf('%s Metrics Over Time', metricName));
    xlabel('Time (s)');
    ylabel('Pair Index');
    set(gca, 'FontSize', 12);

    % Calculate half interval width to shift xticks
    halfIntervalWidth = intervalJump / (2 * Fs);

    % Adjust x-ticks and labels
    xticks(timePoints + halfIntervalWidth); 
    xticklabels(string(timePoints)); % Use string to ensure correct display
    yticks(1:numPairs); % Ensure y-ticks cover all pairs
    yticklabels(selectedPairNames);

    % Add vertical red lines
    hold on;
    x1 = timePoints(9) + halfIntervalWidth;  % 9th index
    x2 = timePoints(end-9) + halfIntervalWidth;  % (end-9)th index
    line([x1 x1], ylim, 'Color', 'red', 'LineWidth', 2); % First red line
    line([x2 x2], ylim, 'Color', 'red', 'LineWidth', 2); % Second red line
    hold off;
end