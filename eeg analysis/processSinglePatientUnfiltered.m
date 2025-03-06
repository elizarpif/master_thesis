function patientResults = processSinglePatientUnfiltered(patientNum, basePath, Fs, downsamplingFactor)
    % Process unfiltered EEG data for a single patient
    % Inputs:
    %   patientNum - patient number (1-16)
    %   basePath - base path to the dataset
    %   Fs - sampling frequency
    %   downsamplingFactor - factor for downsampling
    % Output:
    %   patientResults - struct containing results for all seizures of the patient
    
    % Format patient number with leading zero if needed
    patientStr = sprintf('%02d', patientNum);
    patientPath = fullfile(basePath, patientStr);
    
    % Get list of seizure files for this patient
    seizureFiles = dir(fullfile(patientPath, 'P*_Sz*_block37.mat'));
    
    % Initialize results for this patient
    patientResults = struct();
    patientResults.patientNum = patientNum;
    patientResults.seizureResults = cell(length(seizureFiles), 1);
    
    % Calculate derived constants
    newFs = Fs/downsamplingFactor;
    
    % Process each seizure file for this patient
    for szFileIdx = 1:length(seizureFiles)
        % Load data from file
        data = load(fullfile(patientPath, seizureFiles(szFileIdx).name));
        eegDataOriginal = data.EEG';
        
        % Get channel information
        channelNameArray = data.channelNameArray;
        numChannels = length(channelNameArray);
        
        % Downsample EEG data
        downsampledEEGData = downsampleEEGData(eegDataOriginal, Fs, downsamplingFactor);
        lengthData = length(downsampledEEGData);
        
        % Calculate intervals
        intervalJump = 10240 / downsamplingFactor;
        totalIntervals = floor(lengthData / intervalJump);
        numPairs = floor(numChannels / 2);
        
        % Initialize arrays for metrics
        L_XY_unfiltered = zeros(numPairs, totalIntervals);
        R_unfiltered = zeros(numPairs, totalIntervals);
        
        % Prepare channel pairs
        selectedPairs = cell(1, numPairs);
        selectedPairNames = strings(numPairs, 1);
        
        for idx = 1:numPairs
            eegIdx = 2 * idx - 1;
            pair = downsampledEEGData(eegIdx:eegIdx + 1, :);
            selectedPairs{idx} = pair;
            selectedPairNames(idx) = sprintf('%s-%s', channelNameArray{eegIdx}, channelNameArray{eegIdx + 1});
        end
        
        % Process each interval
        for intervalIndex = 1:totalIntervals
            interval = intervalIndex * intervalJump;
            r = interval;
            l = interval-intervalJump+1;
            
            % Compute metrics for each pair
            for idx = 1:numPairs
                pair = selectedPairs{idx}(:,l:r);
                
                % Compute L metric
                L = computeLMetric(pair, downsamplingFactor);
                L_XY_unfiltered(idx, intervalIndex) = L(1);
                
                % Compute R metric
                R_unfiltered(idx, intervalIndex) = computeRMetric(pair);
            end
            
            logger(sprintf("Patient %s, Seizure %d, Processing completed for interval [%d, %d]", ...
                patientStr, szFileIdx, l, r));
        end
        
        % Get time point names and calculate seizure location
        timePointNames = getTimePointNames(intervalJump, lengthData, newFs);
        percentEndSeizureLocation = (lengthData/newFs - 180) / (20*100);
        
        % Store results for this seizure
        seizureResult = struct();
        seizureResult.L_XY_unfiltered = L_XY_unfiltered;
        seizureResult.R_unfiltered = R_unfiltered;
        seizureResult.timePointNames = timePointNames;
        seizureResult.percentEndSeizureLocation = percentEndSeizureLocation;
        seizureResult.selectedPairNames = selectedPairNames;
        seizureResult.numPairs = numPairs;
        
        patientResults.seizureResults{szFileIdx} = seizureResult;
    end
end 