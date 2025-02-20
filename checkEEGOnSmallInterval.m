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
    logger(sprintf("started for %s", bands(bandIndex)));

    selectedFilteredPairs = filterEEGByBand(selectedPairs, newFs, bands(bandIndex));
    intervalIndex = 1;

    for interval = 0:intervalJump:lengthData
        l = interval + 1;
        r = min(interval + intervalJump, lengthData);

        for idx = 1:numPairs
            pair = selectedFilteredPairs{idx}(:, l:r);
            L = computeLMetric(pair, downsamplingFactor);

            L_XY_all(bandIndex, idx, intervalIndex) = L(1);
            L_YX_all(bandIndex, idx, intervalIndex) = L(2);
            R_all(bandIndex, idx, intervalIndex) = computeRMetric(pair);
        end

        intervalIndex = intervalIndex + 1;
        logger(sprintf("Processed interval [%d, %d]", l, r));
    end
end


timePointNames = getTimePointNames(intervalJump, lengthData, newFs);
percentEndSeizureLocation = (lengthData/newFs - 180) / (20*100) ;

save("pat16_part1_results.mat",'L_XY_all', 'R_all', 'numPairs', 'timePointNames', 'percentEndSeizureLocation', 'selectedPairNames');

L_XY_all_alpha = squeeze(L_XY_all(1, :, :));
L_XY_all_beta = squeeze(L_XY_all(2, :, :));
R_all_alpha = squeeze(R_all(1, :, :));

differenceMask = abs(L_XY_all_alpha - L_XY_all_beta) > 0.3;

colorbarMin = min([min(L_XY_all_alpha(:)), min(L_XY_all_beta(:))]);
colorbarMax = max([max(L_XY_all_alpha(:)), max(L_XY_all_beta(:))]);

eegImagescResultMask(timePointNames, L_XY_all_alpha, numPairs, ...
    percentEndSeizureLocation, sprintf("L_{XY} (%s)", bands(1)), ...
    selectedPairNames, differenceMask, colorbarMin, colorbarMax);
eegImagescResultMask(timePointNames, L_XY_all_beta, numPairs, ...
    percentEndSeizureLocation, sprintf("L_{XY} (%s)", bands(2)), ...
    selectedPairNames, differenceMask, colorbarMin, colorbarMax);
