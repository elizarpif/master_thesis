% Load data from file
data = load("bern dataset/100 seizures/Pat16/P16_Sz1_block37.mat");
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
    for interval = 0:intervalJump:lengthData
        if interval > lengthData
            disp('Break: Interval exceeds data length')
            break;
        end

        % Calculate indices for the current slice of data
        l = interval+1;
        r = min(interval + intervalJump, lengthData);  % Ensure r does not exceed data length

        % Compute metrics L and R for each pair
        for idx = 1:numPairs
            pair = selectedFilteredPairs{idx}(:,l:r);

            % Compute L metric
            res = computeLMetric(pair, downsamplingFactor);
            L_XY_all(bandIndex, idx, intervalIndex) = res(1);
            L_YX_all(bandIndex, idx, intervalIndex) = res(2);

            % Compute R metric
            R_all(bandIndex, idx, intervalIndex) = computeRMetric(pair);
        end

        intervalIndex = intervalIndex+1;
        logger(sprintf("Processing completed for interval [%d, %d]", l, r));
    end
end

timePoints = (0:intervalJump:lengthData) / newFs;
L_XY_all_alpha = L_XY_all(1,:,:);

save("pat16_part1_results.mat",'L_XY_all', 'R_all', 'numPairs', 'intervalJump', 'newFs', 'timePoints', 'selectedPairNames');

% eegImagescResult(timePoints, L_XY_all, numPairs, intervalJump, newFs, sprintf("L_{XY} (%s)", bandName),selectedPairNames);
% eegImagescResult(timePoints, L_YX_all, numPairs, intervalJump, newFs, sprintf("L_{YX} (%s)", bandName),selectedPairNames);
% eegImagescResult(timePoints, R_all, numPairs, intervalJump, newFs, sprintf("R (%s)", bandName),selectedPairNames);
% eegImagescResult(timePoints, (L_XY_all - L_YX_all), numPairs, intervalJump, newFs, sprintf("delta L (%s)", bandName), selectedPairNames);
% eegImagescResult(timePoints, abs(L_XY_all - L_YX_all), numPairs, intervalJump, newFs, sprintf("abs delta L (%s)", bandName), selectedPairNames);

%
