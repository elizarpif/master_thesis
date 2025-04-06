function processSinglePatientUnfiltered(patientNum)
% Process EEG data for a single patient
% Inputs:
%   patientNum - patient number (1-16)


patientPath = sprintf('dataset/100 seizures/Pat%d', patientNum);

seizureFiles = dir(fullfile(patientPath, 'P*_Sz*_block37.mat'));

% % Initialize results for this patient
% patientResults = struct();
% patientResults.patientNum = patientNum;
% patientResults.seizureResults = cell(length(seizureFiles), 1);

Fs = 512; % Sampling frequency (Hz)
downsamplingFactor = 4;
newFs = Fs/downsamplingFactor;

for szFileIdx = 1:length(seizureFiles)
    openFilename = seizureFiles(szFileIdx).name;
    logger(sprintf("opened %s", openFilename));
    data = load(fullfile(patientPath, openFilename));
    eegDataOriginal = data.EEG';

    % Define sampling frequency and time vector
    total_duration = length(eegDataOriginal(1, :)) / Fs;
    Ts = 1 / Fs; % Sampling interval (s)

    % Channel information
    channelNameArray = data.channelNameArray;
    numChannels = length(channelNameArray); % Number of EEG channels

    downsampledEEGData = downsampleEEGData(eegDataOriginal, Fs, downsamplingFactor);
    lengthData = length(downsampledEEGData);

    intervalJump = 10240 / downsamplingFactor; % because of the downsampling
    totalIntervals = floor(lengthData / intervalJump);
    numPairs = floor(numChannels / 2);

    L_XY_all = zeros(numPairs, totalIntervals);
    L_YX_all = zeros(numPairs, totalIntervals);
    R_all = zeros(numPairs, totalIntervals);

    selectedPairs = cell(1, numPairs);
    selectedPairNames = strings(numPairs, 1);

    for idx = 1:numPairs
        eegIdx = 2 * idx - 1;
        pair = downsampledEEGData(eegIdx:eegIdx + 1, :);
        selectedPairs{idx} = pair;
        selectedPairNames(idx) = sprintf('%s-%s', channelNameArray{eegIdx}, channelNameArray{eegIdx + 1});
    end

    intervalIndex = 1; % Initialize interval index

    % Process each interval of EEG data
    for interval = intervalJump:intervalJump:lengthData

        % r = 2560 (20), 5120 (40), 60 ..., 440
        r = interval;
        % l = 1 (0), 2561 (20), 40..., 420
        l = interval-intervalJump+1;
        % Compute metrics L and R for each pair

        for idx = 1:numPairs
            pair = selectedPairs{idx}(:,l:r);

            % Compute L metric
            res = computeLMetric(pair, downsamplingFactor);
            L_XY_all(idx, intervalIndex) = res(1);
            L_YX_all(idx, intervalIndex) = res(2);

            % Compute R metric
            R_all(idx, intervalIndex) = computeRMetric(pair);
        end

        intervalIndex = intervalIndex+1;
        logger(sprintf("Processing completed for interval [%d, %d]", l, r));
    end

    timePointNames = getTimePointNames(intervalJump, lengthData, newFs);
    % ["20","40",..,"440"]
    percentEndSeizureLocation = mod(lengthData/newFs - 180, 20) / 20 ;

    filename = sprintf("pat%d_%d_all_results_unfiltered.mat", patientNum, szFileIdx);
    save(filename,'L_XY_all', 'L_YX_all','R_all', 'numPairs', 'timePointNames', 'percentEndSeizureLocation', 'selectedPairNames');

    logger(sprintf("saved %s",filename));
    %
    % % Store results for this seizure
    % seizureResult = struct();
    % seizureResult.L_XY_all = L_XY_all;
    % seizureResult.L_YX_all = L_YX_all;
    % seizureResult.R_all = R_all;
    % seizureResult.timePointNames = timePointNames;
    % seizureResult.percentEndSeizureLocation = percentEndSeizureLocation;
    % seizureResult.selectedPairNames = selectedPairNames;
    % seizureResult.numPairs = numPairs;
    %
    % patientResults.seizureResults{szFileIdx} = seizureResult;
end
end