function filteredEEG = filterEEGByBand(eegData, newFs, bandname)
numChannels = size(eegData, 1);
filteredEEG = zeros(numChannels, length(eegData));

for i = 1:numChannels
    channelData = eegData(i, :);
    filteredEEG(i, :) = filterByBand(channelData, newFs, bandname);
end
end

function filteredEEGData = filterByBand(eegData, Fs, bandname)
band = [0.5 256];

if bandname == "theta"
    band = [4 8];
elseif bandname == "delta"
    band = [0.5 4];
elseif bandname == "alpha"
    band = [8 12];
elseif bandname == "beta"
    band = [12 31];
end
% [4 8] theta
% [0.5 4] delta
% [8 12] alpha
% [12 31] beta

% Создание полосового фильтра Баттерворта для поиска спайков
% . means right array divide 
[b, a] = butter(3, band./(Fs/2), 'bandpass');

% Применение фильтрации к данным ЭЭГ
filteredEEGData = filtfilt(b, a, eegData);
end