function [outliers, residuals, coeffs] = detectOutliers(X, Y, degree)
    % Detect outliers using polynomial regression
    % Inputs:
    %   X - L metric values
    %   Y - R metric values
    %   degree - degree of polynomial regression (default: 3)
    % Outputs:
    %   outliers - logical array indicating which points are outliers
    %   residuals - array of residuals for each point
    %   coeffs - coefficients of the polynomial regression
    
    if nargin < 3
        degree = 3;
    end
    
    % 1. Polynomial regression
    coeffs = polyfit(X, Y, degree);
    Y_pred = polyval(coeffs, X);
    
    % 2. Calculate residuals
    residuals = abs(Y - Y_pred);
    
    % 3. Determine outliers (if residual is above 4 standard deviations)
    threshold = 4 * std(residuals);
    outliers = residuals > threshold;
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