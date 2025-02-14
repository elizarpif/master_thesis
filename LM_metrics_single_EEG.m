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

bandName = "delta";

downsamplingFactor = 1;
newFs = Fs/downsamplingFactor;

downsampledEEGData = downsampleEEGData(eegDataOriginal, Fs, downsamplingFactor);
filteredEEGData = filterEEGByBand(downsampledEEGData, newFs, bandName);

% figure;
% [pxx, f] = periodogram(filteredEEGData(45,:), [], [], Fs);
% plot(f, 10*log10(pxx), 'b'); 
% title('Periodogram');
% xlabel('Frequency (Hz)');
% ylabel('Power (dB/Hz)');
% grid on;

% PlotEEG(filteredEEGData, channelNameArray, newFs, bandName);

% Set interval jump for processing
intervalJump = 10240 / downsamplingFactor; % because of the downsampling
totalIntervals = floor(length(filteredEEGData) / intervalJump);

% Initialize overall storage for metrics
numPairs = floor(numChannels / 2);
L_XY_all = zeros(numPairs, totalIntervals);
L_YX_all = zeros(numPairs, totalIntervals);
R_all = zeros(numPairs, totalIntervals);

intervalIndex = 0; % Initialize interval index

% FOR NOW DON't include the last piece (it is 3 seconds)
% because I don't know how to put it on the plot and how to measure the end
% of the seizure (only approximately?)

% Process each interval of EEG data
for interval = 0:intervalJump:length(filteredEEGData)
    if interval > length(filteredEEGData)
        disp('Break: Interval exceeds data length')
        break;
    end

    % Increase interval index
    intervalIndex = intervalIndex + 1;

    % Calculate indices for the current slice of data
    l = interval+1;
    r = min(interval + intervalJump, length(filteredEEGData));  % Ensure r does not exceed data length


    % Create pairs of EEG channels
    selectedPairs = cell(1, numPairs);
    selectedPairNames = strings(numPairs, 1);

    for idx = 1:numPairs
        eegIdx = 2 * idx - 1;
        pair = filteredEEGData(eegIdx:eegIdx + 1, l:r);
        selectedPairs{idx} = pair;
        selectedPairNames(idx) = sprintf('%s-%s', channelNameArray{eegIdx}, channelNameArray{eegIdx + 1});
    end

    % Compute metrics L and R for each pair
    for idx = 1:numPairs
        % Compute L metric
        res = computeLMetric(selectedPairs{idx}, downsamplingFactor);
        L_XY_all(idx, intervalIndex) = res(1);
        L_YX_all(idx, intervalIndex) = res(2);

        % Compute R metric
        R_all(idx, intervalIndex) = computeRMetric(selectedPairs{idx});
    end
    % Log processing completion
    logger(sprintf("Processing completed for interval [%d, %d]", l, r));
end

timePoints = (0:intervalJump:length(filteredEEGData)) / newFs;
% Ensure the last time point is included
% finalTime = length(filteredEEGData) / newFs;
% if timePoints(end) < finalTime
%     timePoints = [timePoints, finalTime];
% end

eegImagescResult(timePoints, L_XY_all, numPairs, intervalJump, newFs, sprintf("L_{XY} (%s)", bandName),selectedPairNames);
% eegImagescResult(timePoints, L_YX_all, numPairs, intervalJump, newFs, sprintf("L_{YX} (%s)", bandName),selectedPairNames);
eegImagescResult(timePoints, R_all, numPairs, intervalJump, newFs, sprintf("R (%s)", bandName),selectedPairNames);
% eegImagescResult(timePoints, (L_XY_all - L_YX_all), numPairs, intervalJump, newFs, sprintf("delta L (%s)", bandName), selectedPairNames);
% eegImagescResult(timePoints, abs(L_XY_all - L_YX_all), numPairs, intervalJump, newFs, sprintf("abs delta L (%s)", bandName), selectedPairNames);

%
