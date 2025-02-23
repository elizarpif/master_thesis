function eegImagescResult(timePointNames, pairsValues, numPairs, ...
    percentEndSeizureLocation, metricName, selectedPairNames, colorbarMin, colorbarMax)

    % Adjust x-ticks
    xValues = 1:size(pairsValues, 2);

    % figure;
    imagesc(xValues, 1:numPairs, pairsValues);
    colorbar;
    caxis([colorbarMin colorbarMax]);
    title(sprintf('%s Metrics Over Time', metricName));
    xlabel('Time (s)');
    ylabel('Pair Index');
    set(gca, 'FontSize', 12);

    halfIntervalWidth = 0.5;
    xticks(xValues + halfIntervalWidth);
    xticklabels(timePointNames);
    yticks(1:numPairs);
    yticklabels(selectedPairNames);

    % Add vertical lines
    hold on;
    x1 = xValues(10) - halfIntervalWidth; % First vertical line (solid)
    x2 = xValues(end-9) - halfIntervalWidth + percentEndSeizureLocation; % Adjusted second vertical line (dashed)
    
    xline(x1, 'r', 'LineWidth', 2);   % Solid red line
    xline(x2, '--r', 'LineWidth', 2); % Dashed red line
    
    hold off;

end
