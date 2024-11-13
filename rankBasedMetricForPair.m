data = load("bern dataset/100 seizures/Pat16/P16_Sz1_block37.mat");

eegData = data.EEG';
channelNameArray = data.channelNameArray;

numChannels = 64;  % Number of EEG channels
cutEEGData = zeros(numChannels,length(eegData)/2);  % Preallocate matrix for filtered and downsampled data

for i = 1:numChannels
    channelData = eegData(i,:);
    downsampledData = downsample(channelData, 2);
    cutEEGData(i, :) = downsampledData;
end

numPairs = floor(size(cutEEGData, 1) / 2);  % Compute the number of pairs
selectedPairs = cell(1, numPairs);  % Preallocate the cell array to improve performance

for idx = 1:numPairs
    eegIdx = 2 * idx - 1;  % Compute the start index for the pair
    pair = cutEEGData(eegIdx:eegIdx + 1, :, :);  % Extract the pair
    selectedPairs{idx} = pair;  % Store the pair directly
end

embedding_dim = 6;
tau = 3;
theiler_correction = 30;
k = 3;

% embedding_dim = 8;
% tau = 8;
% theiler_correction = 38;
% k = 5;

LPairs = cell(1, numPairs);
for idx=1:numPairs
    Datarec = [cutEEGData(2*idx-1,1:500)', cutEEGData(2*idx,1:500)'];

    % `krec is an array of numbers of nearest neighbors k`, 
    % I put only number 3.
    res = HSLMNCom(Datarec,embedding_dim,tau,k,theiler_correction);
    LPairs{idx} = res(2,:);
end 

dataMatrix = cell2mat(LPairs'); % Transpose the cell array and convert to matrix

%% Create a heatmap
figure;
imagesc(dataMatrix);
colorbar;
xlabel('Index within Each Pair');
ylabel('Pair Index');
title('Heatmap of Results from HSLMNCom');