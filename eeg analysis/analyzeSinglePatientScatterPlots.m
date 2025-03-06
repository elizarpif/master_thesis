% Script to analyze scatter plots for a single patient's unfiltered data
function analyzeSinglePatientScatterPlots(patientNum)
    % Input:
    %   patientNum - patient number (1-16)
    
    % Load the unfiltered results for this patient
    filename = sprintf('pat%02d_all_results_unfiltered.mat', patientNum);
    
    if exist(filename, 'file')
        % Load the data
        data = load(filename);
        patientResults = data.patientResultsUnfiltered;
        
        % Create a table to store all outlier results for this patient
        patientOutliers = table();
        
        % Process each seizure for this patient
        for szIdx = 1:length(patientResults.seizureResults)
            seizureResult = patientResults.seizureResults{szIdx};
            
            % Analyze scatter plot for this seizure
            analyzeScatterPlot(seizureResult.L_XY_unfiltered, seizureResult.R_unfiltered, ...
                seizureResult.selectedPairNames, seizureResult.timePointNames, patientNum, szIdx);
            
            % Save the figures
            saveas(gcf, sprintf('scatter_plot_pat%02d_sz%d.fig', patientNum, szIdx));
            saveas(gcf, sprintf('scatter_plot_pat%02d_sz%d.png', patientNum, szIdx));
            
            % Save the outlier visualization
            saveas(gcf, sprintf('outliers_plot_pat%02d_sz%d.fig', patientNum, szIdx));
            saveas(gcf, sprintf('outliers_plot_pat%02d_sz%d.png', patientNum, szIdx));
            
            % Close the figures to free up memory
            close all;
            
            % Read the CSV file with outliers for this seizure
            csv_filename = sprintf('outliers_pat%02d_sz%d.csv', patientNum, szIdx);
            if exist(csv_filename, 'file')
                seizureOutliers = readtable(csv_filename);
                seizureOutliers.Seizure = repmat(szIdx, height(seizureOutliers), 1);
                patientOutliers = [patientOutliers; seizureOutliers];
            end
        end
        
        % Save all outlier results for this patient
        writetable(patientOutliers, sprintf('patient%02d_all_outliers.csv', patientNum));
        
        % Display summary statistics for this patient
        fprintf('\nSummary of Outliers for Patient %02d:\n', patientNum);
        fprintf('Total number of outliers: %d\n', height(patientOutliers));
        fprintf('Number of seizures with outliers: %d\n', length(unique(patientOutliers.Seizure)));
        
        % Display outliers per seizure
        fprintf('\nOutliers per seizure:\n');
        for szIdx = 1:length(patientResults.seizureResults)
            seizureCount = sum(patientOutliers.Seizure == szIdx);
            fprintf('Seizure %d: %d outliers\n', szIdx, seizureCount);
        end
        
        % Display outliers per channel pair
        fprintf('\nOutliers per channel pair:\n');
        uniquePairs = unique(patientOutliers.Pair);
        for pairIdx = 1:length(uniquePairs)
            pair = uniquePairs{pairIdx};
            pairCount = sum(strcmp(patientOutliers.Pair, pair));
            fprintf('%s: %d outliers\n', pair, pairCount);
        end
        
    else
        warning('File %s not found. Please check the patient number.', filename);
    end
end 