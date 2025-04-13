function eegImagescResult(timePointNames, pairsValues, numPairs, ...
    percentEndSeizureLocation, metricName, fileName, selectedPairNames, colorbarMin, colorbarMax)

    % xValues = 1,2,3,4,5...22
    xValues = 1:size(pairsValues, 2);

    f = figure;
    imagesc(xValues, 1:numPairs, pairsValues);
    colorbar;
    caxis([colorbarMin colorbarMax]);
    title(sprintf('%s Metrics Over Time', metricName));
    xlabel('Time (s)');
    ylabel('Pair Index');
    set(gca, 'FontSize', 12);

    halfIntervalWidth = 0.5;
    % 1.5,2.5,3.5,..,22.5
    xticks(xValues + halfIntervalWidth);
    xticklabels(timePointNames);
    yticks(1:numPairs);
    yticklabels(selectedPairNames);

    % Add vertical lines
    hold on;
    % we need to put the line after the square, thats why we take 10 instead of
    % 9
    x1 = xValues(10) - halfIntervalWidth; % First vertical line (solid)
    % same, we need to put the line after the square, thats why we take instead of 
    % 9; 
    x2 = xValues(end-8) - halfIntervalWidth + percentEndSeizureLocation; % Adjusted second vertical line (dashed)

    xline(x1, 'r', 'LineWidth', 2);   % Solid red line
    xline(x2, '--r', 'LineWidth', 2); % Dashed red line
    
    hold off;

    if fileName ~= ""
        saveas(f, fileName); 
    end

end
