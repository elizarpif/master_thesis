% Script to analyze scatter plots for all saved unfiltered data
numPatients = 16;

% Loop through each patient
for patientNum = 1:numPatients
    % Load the unfiltered results for this patient
    filename = sprintf('pat%02d_all_results_unfiltered.mat', patientNum);
    
    if exist(filename, 'file')
        % Load the data
        data = load(filename);
        patientResults = data.patientResultsUnfiltered;
        
        % Process each seizure for this patient
        for szIdx = 1:length(patientResults.seizureResults)
            seizureResult = patientResults.seizureResults{szIdx};
            
            % Analyze scatter plot for this seizure
            analyzeScatterPlot(seizureResult.L_XY_unfiltered, seizureResult.R_unfiltered, ...
                seizureResult.selectedPairNames, seizureResult.timePointNames, patientNum, szIdx);
            
            % Save the figure
            saveas(gcf, sprintf('scatter_plot_pat%02d_sz%d.fig', patientNum, szIdx));
            saveas(gcf, sprintf('scatter_plot_pat%02d_sz%d.png', patientNum, szIdx));
            
            % Save the outlier visualization
            saveas(gcf, sprintf('outliers_plot_pat%02d_sz%d.fig', patientNum, szIdx));
            saveas(gcf, sprintf('outliers_plot_pat%02d_sz%d.png', patientNum, szIdx));
            
            % Close the figures to free up memory
            close all;
        end
    else
        warning('File %s not found. Skipping patient %d.', filename, patientNum);
    end
end

% Create a summary of all outliers
allOutliers = table();
for patientNum = 1:numPatients
    % Find all CSV files for this patient
    csvFiles = dir(sprintf('outliers_pat%02d_sz*.csv', patientNum));
    
    for fileIdx = 1:length(csvFiles)
        % Extract seizure number from filename
        filename = csvFiles(fileIdx).name;
        seizureNum = str2double(regexp(filename, 'sz(\d+)', 'tokens', 'once'));
        
        % Read the CSV file
        patientOutliers = readtable(filename);
        
        % Add patient and seizure information
        patientOutliers.Patient = repmat(patientNum, height(patientOutliers), 1);
        patientOutliers.Seizure = repmat(seizureNum, height(patientOutliers), 1);
        
        % Append to main table
        allOutliers = [allOutliers; patientOutliers];
    end
end

% Save the combined outliers table
writetable(allOutliers, 'all_outliers_summary.csv');

% Display summary statistics
fprintf('\nSummary of Outliers:\n');
fprintf('Total number of outliers: %d\n', height(allOutliers));
fprintf('Number of patients with outliers: %d\n', length(unique(allOutliers.Patient)));
fprintf('Number of seizures with outliers: %d\n', length(unique([allOutliers.Patient, allOutliers.Seizure], 'rows')));

% Display outliers per patient
fprintf('\nOutliers per patient:\n');
for patientNum = 1:numPatients
    patientCount = sum(allOutliers.Patient == patientNum);
    fprintf('Patient %02d: %d outliers\n', patientNum, patientCount);
end 