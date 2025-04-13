function visualiseChannels( x, y, channelNameArray, plotTitle )
    nChan = length(channelNameArray);
    
    % Calculate default interval for channel separation
    global amplitude_parameter;
    interval = mean(range(y, 2)) * nChan / amplitude_parameter;
    
    % Create vertical offsets for each channel
    y_center = linspace(-interval, interval, nChan);
    
    % % Define a colormap for the channels
    % color_template = [0 100 0;
    %                    0 200 0;
    %                    0 300 0;
    %                    100 0 100;
    %                    100 0 200] * 0.001;

    color_template = [0 0 0;
                  0 0 0;
                  0 0 0;
                  0 0 0;
                  0 0 0];
    c_space = repmat(color_template, [ceil(nChan/size(color_template, 1)), 1]);

    % Main plot
    % Remove underscores from each element:
    channelNameArray = cellfun(@(x) strrep(x, '_', ''), channelNameArray, 'UniformOutput', false);

    channelLabel = flip(channelNameArray); % Channel labels
    channelLabelPosition = []; % Y-axis positions for channel labels
    lw = 1; % Line width

    % figure
    for chanIdx = 1:nChan
        shift = y_center(chanIdx) + nanmean(y(chanIdx, :), 2);
        
        plot(x, y(chanIdx, :) - shift, 'Color', c_space(chanIdx, :), 'LineWidth', lw);
        
        channelLabelPosition(chanIdx) = y_center(chanIdx); % Y-axis positions for labels
        if chanIdx == 1
            hold on;
        end
    end
    hold off;

    ax = gca;
    % Enhance visibility and customize plot
    set(ax, 'YTick', channelLabelPosition, 'YTickLabel', channelLabel, 'Clipping', 'on', 'Box', 'off', 'LineWidth', 2);
    ax.XAxis.FontSize = 16;
    ax.YAxis.FontSize = 14;
    ylim([-1 1] * interval*1.05); % Set Y-axis limits
    xlim([1 400])

    xlabel('Time (s)');
    ylabel('Channel Data');
    title(plotTitle);
end