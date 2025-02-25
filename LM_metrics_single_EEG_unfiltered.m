% Load data from file
data = load("bern dataset/100 seizures/Pat16/P16_Sz1_block37.mat");
eegDataOriginal = data.EEG';

% Sampling params
Fs = 512;
total_duration = length(eegDataOriginal(1, :)) / Fs;
Ts = 1 / Fs;
% time_vector = 0:Ts:total_duration;

downsamplingFactor = 4;
newFs = Fs/downsamplingFactor;

downsampledEEGData = downsampleEEGData(eegDataOriginal, Fs, downsamplingFactor);
lengthData = length(downsampledEEGData);

% Channel information
channelNameArray = data.channelNameArray;
numChannels = length(channelNameArray); % Number of EEG channels

intervalJump = 10240 / downsamplingFactor;
totalIntervals = floor(lengthData / intervalJump);
numPairs = floor(numChannels / 2);

L_XY_unfiltered = zeros(numPairs, totalIntervals);
R_unfiltered = zeros(numPairs, totalIntervals);

selectedPairs = cell(1, numPairs);
selectedPairNames = strings(numPairs, 1);

for idx = 1:numPairs
    eegIdx = 2 * idx - 1;
    pair = downsampledEEGData(eegIdx:eegIdx + 1, :);
    selectedPairs{idx} = pair;
    selectedPairNames(idx) = sprintf('%s-%s', channelNameArray{eegIdx}, channelNameArray{eegIdx + 1});
end

selectedFilteredPairs = selectedPairs;
intervalIndex = 1;

for interval = intervalJump:intervalJump:lengthData
    % r = 2560 (20), 5120 (40), 60 ..., 440
    r = interval;
    % l = 1 (0), 2561 (20), 40..., 420
    l = interval-intervalJump+1; 

    for idx = 1:numPairs
        pair = selectedFilteredPairs{idx}(:, l:r);
        L = computeLMetric(pair, downsamplingFactor);

        L_XY_unfiltered(idx, intervalIndex) = L(1);
        R_unfiltered(idx, intervalIndex) = computeRMetric(pair);
    end

    intervalIndex = intervalIndex + 1;
    logger(sprintf("Processed interval [%d, %d]", l, r));
end


timePointNames = getTimePointNames(intervalJump, lengthData, newFs);
% ["20","40",..,"440"]
percentEndSeizureLocation = (lengthData/newFs - 180) / (20*100) ;

save("pat16_part1_results_unfiltered.mat",'L_XY_unfiltered', 'R_unfiltered', 'numPairs', 'timePointNames', 'percentEndSeizureLocation', 'selectedPairNames');

colorbarMin = min([min(L_XY_unfiltered(:)), min(R_unfiltered(:))]);
colorbarMax = max([max(L_XY_unfiltered(:)), max(R_unfiltered(:))]);

figure;
eegImagescResult(timePointNames, L_XY_unfiltered, numPairs, ...
    percentEndSeizureLocation, sprintf("L_{XY} (unfiltered)"), ...
    selectedPairNames, colorbarMin, colorbarMax);

figure;
eegImagescResult(timePointNames, R_unfiltered, numPairs, ...
    percentEndSeizureLocation, sprintf("R (unfiltered)"), ...
    selectedPairNames, colorbarMin, colorbarMax);
