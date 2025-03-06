function patientResults = processSinglePatient(patientNum, basePath, Fs, downsamplingFactor, bands)
    % Process EEG data for a single patient
    % Inputs:
    %   patientNum - patient number (1-16)
    %   basePath - base path to the dataset
    %   Fs - sampling frequency
    %   downsamplingFactor - factor for downsampling
    %   bands - array of frequency bands to process
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
        L_XY_all = zeros(length(bands), numPairs, totalIntervals);
        L_YX_all = zeros(length(bands), numPairs, totalIntervals);
        R_all = zeros(length(bands), numPairs, totalIntervals);
        
        % Prepare channel pairs
        selectedPairs = cell(1, numPairs);
        selectedPairNames = strings(numPairs, 1);
        
        for idx = 1:numPairs
            eegIdx = 2 * idx - 1;
            pair = downsampledEEGData(eegIdx:eegIdx + 1, :);
            selectedPairs{idx} = pair;
            selectedPairNames(idx) = sprintf('%s-%s', channelNameArray{eegIdx}, channelNameArray{eegIdx + 1});
        end
        
        % Process each frequency band
        for bandIndex = 1:length(bands)
            bandName = bands(bandIndex);
            logger(sprintf("Patient %s, Seizure %d, started for %s", patientStr, szFileIdx, bandName));
            
            selectedFilteredPairs = filterEEGByBand(selectedPairs, newFs, bandName);
            
            % Process each interval
            for intervalIndex = 1:totalIntervals
                interval = intervalIndex * intervalJump;
                r = interval;
                l = interval-intervalJump+1;
                
                % Compute metrics for each pair
                for idx = 1:numPairs
                    pair = selectedFilteredPairs{idx}(:,l:r);
                    
                    % Compute L metric
                    res = computeLMetric(pair, downsamplingFactor);
                    L_XY_all(bandIndex, idx, intervalIndex) = res(1);
                    L_YX_all(bandIndex, idx, intervalIndex) = res(2);
                    
                    % Compute R metric
                    R_all(bandIndex, idx, intervalIndex) = computeRMetric(pair);
                end
                
                logger(sprintf("Patient %s, Seizure %d, Processing completed for interval [%d, %d]", ...
                    patientStr, szFileIdx, l, r));
            end
        end
        
        % Get time point names and calculate seizure location
        timePointNames = getTimePointNames(intervalJump, lengthData, newFs);
        percentEndSeizureLocation = (lengthData/newFs - 180) / (20*100);
        
        % Store results for this seizure
        seizureResult = struct();
        seizureResult.L_XY_all = L_XY_all;
        seizureResult.L_YX_all = L_YX_all;
        seizureResult.R_all = R_all;
        seizureResult.timePointNames = timePointNames;
        seizureResult.percentEndSeizureLocation = percentEndSeizureLocation;
        seizureResult.selectedPairNames = selectedPairNames;
        seizureResult.numPairs = numPairs;
        
        patientResults.seizureResults{szFileIdx} = seizureResult;
    end
end 