% Load data from file
data = load("dataset/100 seizures/Pat16/P16_Sz2_block37.mat");
eegDataOriginal = data.EEG';

% Define sampling frequency and time vector
Fs = 512; % Sampling frequency (Hz)
total_duration = length(eegDataOriginal(1, :)) / Fs;
Ts = 1 / Fs; % Sampling interval (s)
time_vector = 0:Ts:total_duration;

% Channel information
channelNameArray = data.channelNameArray;
numChannels = length(channelNameArray); % Number of EEG channels

downsamplingFactor = 4;
newFs = Fs/downsamplingFactor;

downsampledEEGData = downsampleEEGData(eegDataOriginal, Fs, downsamplingFactor);
lengthData = length(downsampledEEGData);

intervalJump = 10240 / downsamplingFactor; % because of the downsampling
totalIntervals = floor(lengthData / intervalJump);
numPairs = floor(numChannels / 2);

filteredEEG = filterAllEEGByBand(downsampledEEGData, newFs, "delta");
% PlotEEG(downsampledEEGData, channelNameArray, newFs, "unfiltered");
bands = ["alpha", "beta", "theta", "delta"];

L_XY_all = zeros(length(bands), numPairs, totalIntervals);
L_YX_all = zeros(length(bands), numPairs, totalIntervals);
R_all = zeros(length(bands), numPairs, totalIntervals);

selectedPairs = cell(1, numPairs);
selectedPairNames = strings(numPairs, 1);

for idx = 1:numPairs
    eegIdx = 2 * idx - 1;
    pair = downsampledEEGData(eegIdx:eegIdx + 1, :);
    selectedPairs{idx} = pair;
    selectedPairNames(idx) = sprintf('%s-%s', channelNameArray{eegIdx}, channelNameArray{eegIdx + 1});
end

for bandIndex = 1:length(bands)
    bandName = bands(bandIndex);

    logger(sprintf("started for %s", bandName));

    selectedFilteredPairs = filterEEGByBand(selectedPairs, newFs, bandName);

    intervalIndex = 1; % Initialize interval index

    % Process each interval of EEG data
    for interval = intervalJump:intervalJump:lengthData

        % r = 2560 (20), 5120 (40), 60 ..., 440
        r = interval;
        % l = 1 (0), 2561 (20), 40..., 420
        l = interval-intervalJump+1; 
        % Compute metrics L and R for each pair

        for idx = 1:numPairs
            pair = selectedFilteredPairs{idx}(:,l:r);



            % Compute R metric
            R_all(bandIndex, idx, intervalIndex) = computeRMetric(pair);

                        % Compute L metric
            res = computeLMetric(pair, downsamplingFactor);
            L_XY_all(bandIndex, idx, intervalIndex) = res(1);
            L_YX_all(bandIndex, idx, intervalIndex) = res(2);
        end

        intervalIndex = intervalIndex+1;
        logger(sprintf("Processing completed for interval [%d, %d]", l, r));
    end
end

timePointNames = getTimePointNames(intervalJump, lengthData, newFs);
% ["20","40",..,"440"]
percentEndSeizureLocation = (lengthData/newFs - 180) / (20*100) ;

save("pat16_part2_results_bands.mat",'L_XY_all', 'L_YX_all','R_all', 'numPairs', 'timePointNames', 'percentEndSeizureLocation', 'selectedPairNames');
% 
% bandIndex = 1;
% L_XY_all_alpha = squeeze(L_XY_all(bandIndex, :, :));
% R_all_alpha = squeeze(R_all(bandIndex, :, :));
% 
% colorbarMin = min([min(L_XY_all_alpha(:)), min(R_all_alpha(:))]);
% colorbarMax = max([max(L_XY_all_alpha(:)), max(R_all_alpha(:))]);
% 
% eegImagescResult(timePointNames, L_XY_all_alpha, numPairs, ...
%     percentEndSeizureLocation, sprintf("L_{XY} (%s)", bands(bandIndex)), ...
%     selectedPairNames, colorbarMin, colorbarMax);
% eegImagescResult(timePointNames, R_all_alpha, numPairs, ...
%     percentEndSeizureLocation, sprintf("R (%s)", bands(bandIndex)), ...
%     selectedPairNames, colorbarMin, colorbarMax)

