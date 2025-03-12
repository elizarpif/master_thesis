patientNum = 16;
% Load the unfiltered results for this patient
filename = sprintf('pat%02d_part1_results_unfiltered.mat', patientNum);

if exist(filename, 'file')
    % Load the data
    data = load(filename);


    % Create a table to store all outlier results for this patient
    patientOutliers = table();

    seizureResult = data;
    szIdx = 1;

    % Analyze scatter plot for this seizure
    analyzeScatterPlot(seizureResult.L_XY_unfiltered, seizureResult.R_unfiltered, ...
        seizureResult.selectedPairNames, seizureResult.timePointNames, patientNum, szIdx);

end


function analyzeScatterPlot(L_selected, R_selected, selectedPairNames, timePointNames, patientNum, seizureNum, fileName)
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

% Convert time indices to time points
timePointNames_outliers = timePointNames(outlier_times);

% Store outlier information
outlier_data.Pair = selectedPairNames(outlier_pairs);

timePointNames_transformed = cell(size(timePointNames_outliers));
for i = 1:length(timePointNames_outliers)
    t = str2num(timePointNames_outliers{i});
    timePointNames_transformed{i} = sprintf("%d-%d", t - 20, t);
end
outlier_data.TimePoint = timePointNames_transformed;


% Save outliers to CSV file
writetable(outlier_data, fileName);

end

function output_txt = displayPointInfo(event_obj, scatter_handles, selectedPairNames, timePointNames)
pair_idx = find(scatter_handles == event_obj.Target, 1);
time_idx = event_obj.DataIndex;

% logger("pair %d time idx %d pos %f %f", pair_idx, time_idx, pos(1), pos(2));
if ~isempty(pair_idx) && ~isempty(time_idx)
    output_txt = {sprintf('Pair: %s', selectedPairNames{pair_idx}), ...
        sprintf('Time interval: %d', time_idx*20-20)};
    logger(sprintf("%s, time interval %d-%d s", selectedPairNames{pair_idx}, time_idx*20-20, time_idx*20));
else
    output_txt = {'No data found'};
end
end

function visualizeOutliers(X, Y, outliers, coeffs, patientNum, seizureNum)
% Visualize outliers and regression line with data cursor functionality
% Inputs:
%   X - L metric values
%   Y - R metric values
%   outliers - logical array indicating which points are outliers
%   coeffs - coefficients of the polynomial regression
%   patientNum - patient number
%   seizureNum - seizure number

figure;
hold on;
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

function [outliers, residuals, coeffs, bestDegree] = detectOutliers(X, Y)
% Adaptive Outlier Detection using Polynomial Regression

% 1. Select the best polynomial degree using cross-validation
maxDegree = 6;
errors = zeros(maxDegree, 1);

for d = 1:maxDegree
    coeffs_d = polyfit(X, Y, d);
    Y_pred_d = polyval(coeffs_d, X);
    errors(d) = mean(abs(Y - Y_pred_d));
end

[~, bestDegree] = min(errors);
coeffs = polyfit(X, Y, bestDegree);
Y_pred = polyval(coeffs, X);

% 2. Calculate residuals
residuals = abs(Y - Y_pred);

% 3. Adaptive Outlier Detection (Less Aggressive)
% Tukey's Fences with higher multiplier
Q1 = quantile(residuals, 0.25);
Q3 = quantile(residuals, 0.75);
IQR_value = Q3 - Q1;
threshold = Q3 + 3 * IQR_value; % Adjusted from 1.5 → 3 for a more tolerant filter

% Alternative MAD-based approach (More Robust)
mad_res = median(abs(residuals - median(residuals)));
mad_threshold = 5 * mad_res; % Increased from 4 → 5

% Combine Both (More Flexible)
outliers = (residuals > max(threshold, mad_threshold));

% 4. Visualization
figure; hold on;
scatter(X, Y, 'b', 'filled'); % Normal points
scatter(X(outliers), Y(outliers), 'r', 'filled'); % Outliers
plot(sort(X), polyval(coeffs, sort(X)), 'k--', 'LineWidth', 2); % Regression curve

legend('Normal points', 'Outliers', sprintf('Polynomial Regression (degree %d)', bestDegree));
title('Refined Outlier Detection with Adjusted Threshold');
xlabel('L_selected (X)');
ylabel('R_selected (Y)');
hold off;

end
