data = load("bern dataset/100 seizures/Pat14/P14_Sz1_block37.mat");

eegData = data.EEG';

% sampling frequency; data is sampled at 512 Hz
Fs = 512;
total_duration = length(eegData(1,:))/Fs;
Ts = 1/Fs;
time_vector = 0:Ts:total_duration;

l = 160/Ts;
r = 200/Ts;
eegData = eegData(:, l:r);

channelNameArray = data.channelNameArray;

numChannels = length(channelNameArray);  % Number of EEG channels

if mod(size(eegData, 2), 2) ~= 0
    eegData = eegData(:, 1:end-1);  % Trim to make length even
end

% Now downsample and allocate cutEEGData with consistent length
cutEEGData = zeros(numChannels, size(eegData, 2) / 2);

for i = 1:numChannels
    % Extract channel data
    channelData = eegData(i,:);
    downsampledData = downsample(channelData, 2);
    % Store in matrix
    cutEEGData(i, :) = downsampledData;
end

numPairs = floor(size(cutEEGData, 1) / 2);  % Compute the number of pairs
selectedPairs = cell(1, numPairs);  % Preallocate the cell array to improve performance
selectedPairNames = strings(numPairs);

for idx = 1:numPairs
    eegIdx = 2 * idx - 1;  % Compute the start index for the pair
    pair = cutEEGData(eegIdx:eegIdx + 1, :, :);  % Extract the pair
    selectedPairs{idx} = pair;  % Store the pair directly

    selectedPairNames(idx) = sprintf('%s-%s',channelNameArray{eegIdx}, channelNameArray{eegIdx+1});
end

%% parallel workers setup
% poolObj = gcp('nocreate'); % Get the current pool without creating a new one
% if isempty(poolObj)
%     poolObj = parpool; % If no pool, start the default pool
% end
% numWorkers = poolObj.NumWorkers;
% fprintf('Number of workers in the current pool: %d\n', numWorkers);

%% Number of pairs
numPairs = length(selectedPairs);
numColumns = 20;  % (1+19 surr)

% Initialize matrices outside of parfor for clarity
R = zeros(numPairs, numColumns);
R_test = zeros(numPairs, 1);

% parfor idx = 1:length(selectedPairs)
for idx = 1:length(selectedPairs)
    currentArray = selectedPairs{idx};  % Access pre-sliced data for current pair
    channelName = selectedPairNames{idx};  % Access the corresponding channel name

    disp(channelName)

    [R_i, R_test_i] = RCom(currentArray, 0);

    % Assign temporary arrays to the main arrays
    R(idx, :) = R_i;
    R_test(idx) = R_test_i;
end

%% visulaisation
figure;
imagesc(R(:,1));
colorbar;
% Set x-axis ticks to integers
yticks(1:size(R, 1));
yticklabels(selectedPairNames);
ylabel('Row Index');
xticks(1);
title('R for all channels, 160s-200s, Pat14, Sz1');