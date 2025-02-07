% Load data from file
data = load("bern dataset/100 seizures/Pat16/P16_Sz1_block37.mat");
eegDataOriginal = data.EEG';

% Define sampling frequency and time vector
Fs = 512; % Sampling frequency (Hz)
total_duration = length(eegDataOriginal(1, :)) / Fs;
Ts = 1 / Fs; % Sampling interval (s)
time_vector = 0:Ts:total_duration; % Time vector

% Channel information
channelNameArray = data.channelNameArray;
numChannels = length(channelNameArray); % Number of EEG channels


% Anti-aliasing filter
newFs = Fs/2;
newNyquistFreq = newFs/2;
lowpassCutoff = newNyquistFreq-10; % low pass is slightly below the new Nyquist
order = 8; % selected this order as an example
% Создание полосового фильтра Баттерворта для поиска спайков
[b, a] = butter(order, lowpassCutoff / newNyquistFreq, 'low');

% Ensure even number of samples for downsampling
if mod(size(eegDataOriginal, 2), 2) ~= 0
    eegDataOriginal = eegDataOriginal(:, 1:end-1); % Trim to make length even
end

% Downsample data and filter by band
downsampledEEGData = zeros(numChannels, size(eegDataOriginal, 2) / 2);
for i = 1:numChannels
    channelData = eegDataOriginal(i, :);
    filteredChannelData = filter(b, a, channelData);

    downsampledData = downsample(filteredChannelData, 2);
    downsampledEEGData(i, :) = filterByBand(downsampledData, newFs, "delta");
end

% PlotEEG(downsampledEEGData', channelNameArray, newFs, 'theta')

% Set interval jump for processing
intervalJump = 10240 / 2; % Number of samples to jump for each interval
totalIntervals = floor(length(downsampledEEGData) / intervalJump);

% Initialize overall storage for metrics
numPairs = floor(numChannels / 2);
L_XY_all = zeros(numPairs, totalIntervals);
L_YX_all = zeros(numPairs, totalIntervals);
R_all = zeros(numPairs, totalIntervals);

intervalIndex = 0; % Initialize interval index

% Process each interval of EEG data
for interval = intervalJump:intervalJump:length(downsampledEEGData)
    if interval > length(downsampledEEGData)
        disp('Break: Interval exceeds data length')
        break;
    end

    % Increase interval index
    intervalIndex = intervalIndex + 1;

    % Calculate indices for the current slice of data
    l = interval;
    r = min(interval + intervalJump, length(downsampledEEGData));  % Ensure r does not exceed data length


    % Create pairs of EEG channels
    selectedPairs = cell(1, numPairs);
    selectedPairNames = strings(numPairs, 1);

    for idx = 1:numPairs
        eegIdx = 2 * idx - 1;
        pair = downsampledEEGData(eegIdx:eegIdx + 1, l:r);
        selectedPairs{idx} = pair;
        selectedPairNames(idx) = sprintf('%s-%s', channelNameArray{eegIdx}, channelNameArray{eegIdx + 1});
    end

    % Compute metrics L and R for each pair
    for idx = 1:numPairs
        % Compute L metric
        res = computeLMetric(selectedPairs{idx}');
        L_XY_all(idx, intervalIndex) = res(2, 1);
        L_YX_all(idx, intervalIndex) = res(2, 2);

        % Compute R metric
        R_all(idx, intervalIndex) = computeRMetric(selectedPairs{idx}');
    end
    % Log processing completion
    logger(sprintf("Processing completed for interval [%d, %d]", interval-intervalJump, interval));
end

timePoints = (intervalJump:intervalJump:length(downsampledEEGData)) / newFs;

eegImagescResult(timePoints, L_XY_all, numPairs, intervalJump, newFs, 'L_{XY} (delta)',selectedPairNames);
eegImagescResult(timePoints, L_YX_all, numPairs, intervalJump, newFs, 'L_{YX} (delta)',selectedPairNames);
eegImagescResult(timePoints, R_all, numPairs, intervalJump, newFs, 'R (delta)',selectedPairNames);
eegImagescResult(timePoints, (L_XY_all - L_YX_all), numPairs, intervalJump, newFs, 'delta L (delta band)', selectedPairNames);
% eegImagescResult(timePoints, abs(L_XY_all - L_YX_all), numPairs, intervalJump, newFs, 'abs delta L (theta)', selectedPairNames);

%
