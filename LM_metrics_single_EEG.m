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
%
% exampleChannelData = eegData(1, :);
% filteredExampleChannelData = filter(b, a, exampleChannelData);
%
% figure();
% [p, f] = periodogram(exampleChannelData);
% plot(f * Fs / (2*pi), 10*log10(p));
% title('TBR05');
% xlabel('Frequency (Hz)')
% ylabel('Power/frequency (dB/(rad/sample))');
% hold on;
% yline(0, '--r');
% xline(newNyquistFreq, '--r');
% hold off;
%
% %verification
% figure();
% [p, f] = periodogram(filteredExampleChannelData);
% plot(f * Fs / (2*pi), 10*log10(p));
% title('TPL06\_filtered');
% xlabel('Frequency (Hz)');
% ylabel('Power/frequency (dB/(rad/sample))');
% hold on;
% yline(0, '--r');
% xline(newNyquistFreq, '--r');
% hold off;

% Ensure even number of samples for downsampling
if mod(size(eegData, 2), 2) ~= 0
    eegData = eegData(:, 1:end-1); % Trim to make length even
end

% Downsample data
downsampledEEGData = zeros(numChannels, size(eegDataOriginal, 2) / 2);
for i = 1:numChannels
    channelData = eegDataOriginal(i, :);
    filteredChannelData = filter(b, a, channelData);

    downsampledData = downsample(filteredChannelData, 2);
    downsampledEEGData(i, :) = downsampledData;
end


% Set interval jump for processing
intervalJump = 10240 / 2; % Number of samples to jump for each interval
totalIntervals = floor(length(eegDataOriginal) / intervalJump);

% Initialize overall storage for metrics
numPairs = floor(numChannels / 2);
L_XY_all = zeros(numPairs, totalIntervals);
L_YX_all = zeros(numPairs, totalIntervals);
R_all = zeros(numPairs, totalIntervals);


% Process each interval of EEG data
for interval = intervalJump:intervalJump:length(downsampledEEGData)
    if interval + intervalJump > length(downsampledEEGData)
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
    selectedPairNames = strings(numPairs);

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
    logger(sprintf("Processing completed for interval = %d", interval));
end

timePoints = (intervalJump:intervalJump:length(downsampledEEGData)-1) / newFs;

% eegImagescResult(timePoints, L_XY_all, numPairs, intervalJump, Fs, 'L_{XY}');
% eegImagescResult(timePoints, L_YX_all, numPairs, intervalJump, Fs, 'L_{YX}');
% eegImagescResult(timePoints, R_all, numPairs, intervalJump, Fs, 'R');
eegImagescResult(timePoints, abs(L_XY_all - L_YX_all), numPairs, intervalJump, newFs, 'delta L');
%
