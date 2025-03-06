function analyzeScatterPlot(L_selected, R_selected, selectedPairNames, timePointNames, patientNum, seizureNum)
    % Analyze scatter plot of L vs R metrics and save outliers
    % Inputs:
    %   L_selected - L metric values
    %   R_selected - R metric values
    %   selectedPairNames - names of channel pairs
    %   timePointNames - time point names
    %   patientNum - patient number
    %   seizureNum - seizure number
    
    num_pairs = size(L_selected, 1);
    num_times = size(L_selected, 2);
    
    % Create scatter plot
    figure;
    hold on;
    colors = lines(num_pairs);
    scatter_handles = gobjects(num_pairs, 1);
    
    for pair_idx = 1:num_pairs
        scatter_handles(pair_idx) = scatter(L_selected(pair_idx, :), R_selected(pair_idx, :),...
            20, colors(pair_idx, :), 'filled', 'UserData', pair_idx);
    end
    
    xlabel('Metric L');
    ylabel('Metric R');
    title(sprintf('Scatter Plot L vs R (Patient %02d, Seizure %d)', patientNum, seizureNum));
    grid on;
    legend(selectedPairNames, 'Location', 'eastoutside');
    hold off;
    
    % Enable Data Cursor
    dcm = datacursormode(gcf);
    set(dcm, 'UpdateFcn', @(obj, event_obj) displayPointInfo(event_obj, scatter_handles, selectedPairNames, timePointNames));
    
    % Perform outlier detection
    X = L_selected(:);
    Y = R_selected(:);
    
    % Create indices for each point
    [time_indices, pair_indices] = meshgrid(1:num_times, 1:num_pairs);
    pair_indices = pair_indices(:);
    time_indices = time_indices(:);
    
    % Detect outliers
    [outliers, residuals, coeffs] = detectOutliers(X, Y);
    
    % Create table for outliers
    outlier_data = table();
    
    % Get indices of outlier points
    outlier_pairs = pair_indices(outliers);
    outlier_times = time_indices(outliers);
    
    % Map time indices to timePointNames indices
    timePointIndices = ceil(outlier_times / (num_times/length(timePointNames)));
    timePointIndices = min(timePointIndices, length(timePointNames)); % Ensure we don't exceed array bounds
    
    % Store outlier information
    outlier_data.Pair = selectedPairNames(outlier_pairs);
    outlier_data.TimePoint = timePointNames(timePointIndices);
    outlier_data.PairIndex = outlier_pairs;
    outlier_data.TimeIndex = outlier_times;
    outlier_data.L_Value = X(outliers);
    outlier_data.R_Value = Y(outliers);
    outlier_data.Residual = residuals(outliers);
    
    % Save outliers to CSV file
    csv_filename = sprintf('outliers_pat%02d_sz%d.csv', patientNum, seizureNum);
    writetable(outlier_data, csv_filename);
    
    % Visualize outliers
    visualizeOutliers(X, Y, outliers, coeffs, patientNum, seizureNum, pair_indices, selectedPairNames, timePointNames);
end

function output_txt = displayPointInfo(event_obj, scatter_handles, selectedPairNames, timePointNames)
    pair_idx = event_obj.Target.UserData;
    time_idx = event_obj.DataIndex;
    
    if ~isempty(pair_idx) && ~isempty(time_idx)
        % Map time index to timePointNames index
        time_point_idx = ceil(time_idx / (length(scatter_handles(1).XData)/length(timePointNames)));
        time_point_idx = min(time_point_idx, length(timePointNames)); % Ensure we don't exceed array bounds
        
        output_txt = {sprintf('Pair: %s', selectedPairNames{pair_idx}), ...
                     sprintf('Time point: %s', timePointNames{time_point_idx})};
        logger(sprintf("%s, time point %s", selectedPairNames{pair_idx}, timePointNames{time_point_idx}));
    else
        output_txt = {'No data found'};
    end
end

function visualizeOutliers(X, Y, outliers, coeffs, patientNum, seizureNum, pair_indices, selectedPairNames, timePointNames)
    % Visualize outliers and regression line with data cursor functionality
    % Inputs:
    %   X - L metric values
    %   Y - R metric values
    %   outliers - logical array indicating which points are outliers
    %   coeffs - coefficients of the polynomial regression
    %   patientNum - patient number
    %   seizureNum - seizure number
    %   pair_indices - indices of pairs for each point
    %   selectedPairNames - names of channel pairs
    %   timePointNames - time point names
    
    figure;
    hold on;
    
    % Create scatter plots with UserData
    normal_scatter = scatter(X(~outliers), Y(~outliers), 'b', 'filled', ...
        'UserData', pair_indices(~outliers));
    outlier_scatter = scatter(X(outliers), Y(outliers), 'r', 'filled', ...
        'UserData', pair_indices(outliers));
    regression_line = plot(sort(X), polyval(coeffs, sort(X)), 'k--', 'LineWidth', 2);
    
    scatter_handles = [normal_scatter; outlier_scatter];
    
    legend([normal_scatter, outlier_scatter, regression_line], ...
        {'Normal points', 'Outliers', 'Polynomial regression'}, 'Location', 'best');
    title(sprintf('Outlier Detection (Patient %02d, Seizure %d)', patientNum, seizureNum));
    xlabel('L metric');
    ylabel('R metric');
    grid on;
    
    % Enable Data Cursor
    dcm = datacursormode(gcf);
    set(dcm, 'UpdateFcn', @(obj, event_obj) displayPointInfo(event_obj, scatter_handles, selectedPairNames, timePointNames));
    
    hold off;
end

function [outliers, residuals, coeffs] = detectOutliers(X, Y)
    % Detect outliers using polynomial regression and return only outlier indices
    % Inputs:
    %   X - L metric values
    %   Y - R metric values
    % Outputs:
    %   outliers - logical array indicating which points are outliers
    %   residuals - residuals of the polynomial regression
    %   coeffs - coefficients of the polynomial regression

    % 1. Polynomial regression
    degree = 3;
    coeffs = polyfit(X, Y, degree);
    Y_pred = polyval(coeffs, X);
    
    % 2. Calculate residuals
    residuals = abs(Y - Y_pred);
    
    % 3. Determine outliers (if residual is above 4 standard deviations)
    threshold = 4 * std(residuals);
    outliers = residuals > threshold;
    
    % 4. Extract outlier indices
    pair_indices = 1:length(X);
    time_indices = pair_indices;
    
    % Visualize outliers
    visualizeOutliers(X, Y, outliers, coeffs, 16, 1, pair_indices, {'Pair 1', 'Pair 2'}, {'Time Point 1', 'Time Point 2'});
end 