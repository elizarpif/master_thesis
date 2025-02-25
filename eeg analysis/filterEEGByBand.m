function selectedFilteredPairs = filterEEGByBand(selectedPairs, Fs, bandName)

numPairs = length(selectedPairs);

selectedFilteredPairs = cell(1, numPairs);

for i = 1:numPairs
    channelData1 = filterByBand(selectedPairs{i}(1,:), Fs, bandName);
    channelData2 = filterByBand(selectedPairs{i}(2,:), Fs, bandName);

    selectedFilteredPairs{i} = [channelData1; channelData2];
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