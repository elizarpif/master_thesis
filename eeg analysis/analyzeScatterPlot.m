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
            20, colors(pair_idx, :), 'filled');
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
    
    % Perform polynomial regression and outlier detection
    X = L_selected(:);
    Y = R_selected(:);
    
    % Create indices for each point
    [pair_indices, time_indices] = meshgrid(1:num_pairs, 1:num_times);
    pair_indices = pair_indices(:);
    time_indices = time_indices(:);
    
    % Polynomial regression
    degree = 3;
    coeffs = polyfit(X, Y, degree);
    Y_pred = polyval(coeffs, X);
    
    % Calculate residuals and detect outliers
    residuals = abs(Y - Y_pred);
    threshold = 4 * std(residuals);
    outliers = residuals > threshold;
    
    % Create table for outliers
    outlier_data = table();
    outlier_data.Pair = selectedPairNames(pair_indices(outliers));
    outlier_data.TimePoint = timePointNames(time_indices(outliers));
    outlier_data.L_Value = X(outliers);
    outlier_data.R_Value = Y(outliers);
    outlier_data.Residual = residuals(outliers);
    
    % Save outliers to CSV file
    csv_filename = sprintf('outliers_pat%02d_sz%d.csv', patientNum, seizureNum);
    writetable(outlier_data, csv_filename);
    
    % Create visualization of outliers
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

function output_txt = displayPointInfo(event_obj, scatter_handles, selectedPairNames, timePointNames)
    pair_idx = find(scatter_handles == event_obj.Target, 1);
    time_idx = event_obj.DataIndex;
    
    if ~isempty(pair_idx) && ~isempty(time_idx)
        output_txt = {sprintf('Pair: %s', selectedPairNames{pair_idx}), ...
                     sprintf('Time point: %s', timePointNames{time_idx})};
        logger(sprintf("%s, time point %s", selectedPairNames{pair_idx}, timePointNames{time_idx}));
    else
        output_txt = {'No data found'};
    end
end 