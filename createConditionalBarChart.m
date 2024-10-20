function createConditionalBarChart(ax, dataMatrix, testMatrix, titleStr)
    % Create a bar graph on the specified axes
    hBar = bar(ax, dataMatrix, 'FaceColor', 'r');  % Start with all bars in red

    % Set individual bar coloring
    hBar.FaceColor = 'flat';

    % Go through each bar and check corresponding value in the test matrix
    for k = 1:numel(dataMatrix)
        if testMatrix(k) == 0
            hBar.CData(k, :) = [0 0 1];  % Blue if null hypothesis is not rejected
        else
            hBar.CData(k, :) = [1 0 0];  % Red if null hypothesis is rejected
        end
    end

    % Set labels and title
    title(ax, titleStr);

    % Set x-axis labels to channel names
    % xticks(ax, 1:numel(selectedChannelNames));  % Set x-ticks at each bar
    % xticklabels(ax, selectedChannelNames);  % Apply the provided channel names
end
