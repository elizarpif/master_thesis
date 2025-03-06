% Define sampling frequency and other constants
Fs = 512; % Sampling frequency (Hz)
downsamplingFactor = 4;
bands = ["alpha", "beta", "theta", "delta"];

% Define the range of patients and their seizures
numPatients = 16;
basePath = "dataset/100 seizures/Pat";

% Create cell arrays to store results for each patient
allResultsFiltered = cell(numPatients, 1);
allResultsUnfiltered = cell(numPatients, 1);

% Loop through each patient
for patientNum = 1:numPatients
    % Process current patient (filtered data)
    patientResultsFiltered = processSinglePatient(patientNum, basePath, Fs, downsamplingFactor, bands);
    allResultsFiltered{patientNum} = patientResultsFiltered;
    save(sprintf("pat%02d_all_results_bands.mat", patientNum), 'patientResultsFiltered');
    
    % Process current patient (unfiltered data)
    patientResultsUnfiltered = processSinglePatientUnfiltered(patientNum, basePath, Fs, downsamplingFactor);
    allResultsUnfiltered{patientNum} = patientResultsUnfiltered;
    save(sprintf("pat%02d_all_results_unfiltered.mat", patientNum), 'patientResultsUnfiltered');
end

% Save all results
save("all_patients_results_bands.mat", 'allResultsFiltered');
save("all_patients_results_unfiltered.mat", 'allResultsUnfiltered');

% Plot results for the first patient's first seizure as an example
if ~isempty(allResultsFiltered{1}) && ~isempty(allResultsFiltered{1}.seizureResults{1})
    % Plot filtered results (alpha band)
    firstPatientFiltered = allResultsFiltered{1};
    firstSeizureFiltered = firstPatientFiltered.seizureResults{1};
    
    bandIndex = 1;
    L_XY_all_alpha = squeeze(firstSeizureFiltered.L_XY_all(bandIndex, :, :));
    R_all_alpha = squeeze(firstSeizureFiltered.R_all(bandIndex, :, :));
    
    colorbarMin = min([min(L_XY_all_alpha(:)), min(R_all_alpha(:))]);
    colorbarMax = max([max(L_XY_all_alpha(:)), max(R_all_alpha(:))]);
    
    eegImagescResult(firstSeizureFiltered.timePointNames, L_XY_all_alpha, firstSeizureFiltered.numPairs, ...
        firstSeizureFiltered.percentEndSeizureLocation, sprintf("L_{XY} (%s)", bands(bandIndex)), ...
        firstSeizureFiltered.selectedPairNames, colorbarMin, colorbarMax);
    
    eegImagescResult(firstSeizureFiltered.timePointNames, R_all_alpha, firstSeizureFiltered.numPairs, ...
        firstSeizureFiltered.percentEndSeizureLocation, sprintf("R (%s)", bands(bandIndex)), ...
        firstSeizureFiltered.selectedPairNames, colorbarMin, colorbarMax);
    
    % Plot unfiltered results
    firstPatientUnfiltered = allResultsUnfiltered{1};
    firstSeizureUnfiltered = firstPatientUnfiltered.seizureResults{1};
    
    colorbarMin = min([min(firstSeizureUnfiltered.L_XY_unfiltered(:)), min(firstSeizureUnfiltered.R_unfiltered(:))]);
    colorbarMax = max([max(firstSeizureUnfiltered.L_XY_unfiltered(:)), max(firstSeizureUnfiltered.R_unfiltered(:))]);
    
    eegImagescResult(firstSeizureUnfiltered.timePointNames, firstSeizureUnfiltered.L_XY_unfiltered, firstSeizureUnfiltered.numPairs, ...
        firstSeizureUnfiltered.percentEndSeizureLocation, "L_{XY} (unfiltered)", ...
        firstSeizureUnfiltered.selectedPairNames, colorbarMin, colorbarMax);
    
    eegImagescResult(firstSeizureUnfiltered.timePointNames, firstSeizureUnfiltered.R_unfiltered, firstSeizureUnfiltered.numPairs, ...
        firstSeizureUnfiltered.percentEndSeizureLocation, "R (unfiltered)", ...
        firstSeizureUnfiltered.selectedPairNames, colorbarMin, colorbarMax);
end 