function downsampledEEGData = downsampleEEGData(eegDataOriginal, Fs, downsamplingFactor)

% Anti-aliasing filter
newFs = Fs/downsamplingFactor;
newNyquistFreq = newFs/2;
lowpassCutoff = newNyquistFreq-10; % low pass is slightly below the new Nyquist
order = 8; % selected this order as an example
% Создание полосового фильтра Баттерворта для поиска спайков
[b, a] = butter(order, lowpassCutoff / newNyquistFreq, 'low');

% % Ensure even number of samples for downsampling
% if mod(size(eegDataOriginal, 2), downsamplingFactor) ~= 0
%     trimLen = mod(size(eegDataOriginal, 2), downsamplingFactor);
% 
%     eegDataOriginal = eegDataOriginal(:, 1:end-trimLen); % Trim to make length even
% end

numChannels = size(eegDataOriginal, 1);

% Downsample data and filter by band
downsampledEEGData = zeros(numChannels, size(eegDataOriginal, 2) / downsamplingFactor);

for i = 1:numChannels
    channelData = eegDataOriginal(i, :);
    filteredChannelData = filter(b, a, channelData);

    downsampledData = downsample(filteredChannelData, downsamplingFactor);
    downsampledEEGData(i, :) = downsampledData;
end

end