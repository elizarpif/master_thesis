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
    [pair_indices, time_indices] = meshgrid(1:num_pairs, 1:num_times);
    pair_indices = pair_indices(:);
    time_indices = time_indices(:);
    
    % Detect outliers
    [outliers, residuals] = detectOutliers(timePointNames, L_selected, R_selected);
    
    % Create table for outliers
    outlier_data = table();
    outlier_data.Pair = selectedPairNames(pair_indices(outliers));

    new_outliers = reshape(outliers, 32, 22);

    % Get time points using scatter_handles data
    time_indices_outliers = time_indices(outliers);
    timePointNames_outliers = cell(length(time_indices_outliers), 1);
    for i = 1:length(time_indices_outliers)
        % Get the corresponding time point from the original data structure
        time_idx = time_indices_outliers(i);
        timePointNames_outliers{i} = timePointNames{time_idx};
    end
    outlier_data.TimePoint = timePointNames_outliers;

    outlier_data.L_Value = X(outliers);
    outlier_data.R_Value = Y(outliers);
    outlier_data.Residual = residuals(outliers);
    
    % Save outliers to CSV file
    csv_filename = sprintf('outliers_pat%02d_sz%d.csv', patientNum, seizureNum);
    writetable(outlier_data, csv_filename);
    
    % Visualize outliers
    % visualizeOutliers(X, Y, outliers, coeffs, patientNum, seizureNum);
end

function output_txt = displayPointInfo(event_obj, scatter_handles, selectedPairNames, timePointNames)
    pair_idx = find(scatter_handles == event_obj.Target, 1);
    time_idx = event_obj.DataIndex;

    pair_idx = event_obj.Target.UserData;
    
    if ~isempty(pair_idx) && ~isempty(time_idx)
        output_txt = {sprintf('Pair: %s', selectedPairNames{pair_idx}), ...
                     sprintf('Time point: %s', timePointNames{time_idx})};
        logger(sprintf("%s, time point %s", selectedPairNames{pair_idx}, timePointNames{time_idx}));
    else
        output_txt = {'No data found'};
    end
end 

function [pairIndex_outliers, timeIndex_outliers] = detectOutliers(timePointNames, L_selected, R_selected, degree)
    % Detect outliers using polynomial regression and return only outlier indices
    % Inputs:
    %   timePointNames - names of the time points
    %   L_selected - original L metric matrix
    %   R_selected - original R metric matrix
    %   degree - degree of polynomial regression (default: 3)
    % Outputs:
    %   pairIndex_outliers - indices of pairs identified as outliers
    %   timeIndex_outliers - corresponding time indices of outliers

    if nargin < 4
        degree = 3;
    end
    
    % Reshape L_selected and R_selected into column vectors
    num_pairs = size(L_selected, 1);
    num_times = size(L_selected, 2);
    
    X = L_selected(:);
    Y = R_selected(:);
   
    
    % 1. Polynomial regression
    coeffs = polyfit(X, Y, degree);
    Y_pred = polyval(coeffs, X);
    
    % 2. Calculate residuals
    residuals = abs(Y - Y_pred);
    
    % 3. Determine outliers (if residual is above 4 standard deviations)
    threshold = 4 * std(residuals);
    outliers = residuals > threshold;
    
    % 4. Extract outlier indices
    pairIndex_outliers = pair_indices(outliers);
    timeIndex_outliers = time_indices(outliers);
    
    % Visualize outliers
    visualizeOutliers(X, Y, outliers, coeffs, 16, 1);
end


function visualizeOutliers(X, Y, outliers, coeffs, patientNum, seizureNum)
    % Visualize outliers and regression line
    % Inputs:
    %   X - L metric values
    %   Y - R metric values
    %   outliers - logical array indicating which points are outliers
    %   coeffs - coefficients of the polynomial regression
    %   patientNum - patient number
    %   seizureNum - seizure number
    
    figure;
    hold on;
    scatter(X(~outliers), Y(~outliers), 'b', 'filled', 'DisplayName', 'Normal points');
    scatter(X(outliers), Y(outliers), 'r', 'filled', 'DisplayName', 'Outliers');
    plot(sort(X), polyval(coeffs, sort(X)), 'k--', 'LineWidth', 2, 'DisplayName', 'Polynomial regression');
    
    legend('show');
    title(sprintf('Outlier Detection (Patient %02d, Seizure %d)', patientNum, seizureNum));
    xlabel('L metric');
    ylabel('R metric');
    grid on;
    hold off;
end 