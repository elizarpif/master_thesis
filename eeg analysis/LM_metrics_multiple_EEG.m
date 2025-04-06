% Define sampling frequency and other constants

% Define the range of patients and their seizures
numPatients = 15;


% Create cell arrays to store results for each patient
allResultsFiltered = cell(numPatients, 1);
allResultsUnfiltered = cell(numPatients, 1);

% Loop through each patient
for patientNum = 1:9
    % Process current patient (filtered data)
    % processSinglePatientUnfiltered(patientNum);
    processSinglePatient(patientNum);
    % % Process current patient (unfiltered data)
    % processSinglePatientUnfiltered(patientNum, basePath, Fs, downsamplingFactor);

end

