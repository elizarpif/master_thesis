data = load("EEG3.mat");

eegData = data.EEG';
channelNameArray = data.channelNameArray;

numChannels = 64;  % Number of EEG channels
cutEEGData = zeros(numChannels,length(eegData)/2);  % Preallocate matrix for filtered and downsampled data

for i = 1:numChannels
    % Extract channel data
    channelData = eegData(i,:);
    downsampledData = downsample(channelData, 2);
    % Store in matrix
    cutEEGData(i, :) = downsampledData;
end

numPairs = floor(size(cutEEGData, 1) / 2);  % Compute the number of pairs
selectedPairs = cell(1, numPairs);  % Preallocate the cell array to improve performance

for idx = 1:numPairs
    eegIdx = 2 * idx - 1;  % Compute the start index for the pair
    pair = cutEEGData(eegIdx:eegIdx + 1, :, :);  % Extract the pair
    selectedPairs{idx} = pair;  % Store the pair directly
end

%% parallel workers setup
poolObj = gcp('nocreate'); % Get the current pool without creating a new one
if isempty(poolObj)
    poolObj = parpool; % If no pool, start the default pool
end
numWorkers = poolObj.NumWorkers;
fprintf('Number of workers in the current pool: %d\n', numWorkers);

%% Number of pairs
numPairs = length(selectedPairs);
numColumns = 20;  % (1+19 surr)
bands = {'beta'};
numBands = length(bands);

% Initialize matrices outside of parfor for clarity
V = zeros(numPairs, numBands, numColumns);
V_test = zeros(numPairs, numBands, 1);
M = zeros(numPairs, numBands, numColumns);
M_test = zeros(numPairs, numBands, 1);
S = zeros(numPairs, numBands, numColumns);
S_test = zeros(numPairs, numBands, 1);
R = zeros(numPairs, numBands, numColumns);
R_test = zeros(numPairs, numBands, 1);

parfor idx = 1:length(selectedPairs)
    currentArray = selectedPairs{idx};  % Access pre-sliced data for current pair
    channelName = channelNameArray{idx};  % Access the corresponding channel name
    
    disp(channelName)

    % Temporary arrays to collect data within loop to avoid slicing issues
    tempV = zeros(numBands, 20);
    tempV_test = zeros(numBands, 1);
    tempM = zeros(numBands, 20);
    tempM_test = zeros(numBands, 1);
    tempS = zeros(numBands, 20);
    tempS_test = zeros(numBands, 1);
    tempR = zeros(numBands, 20);
    tempR_test = zeros(numBands, 1);

    for i = 1:numBands
        [V_i, V_test_i, M_i, M_test_i, S_i, S_test_i, R_i, R_test_i] = EA_EEG_Main(currentArray, i);

        % Store in temporary variables
        tempV(i, :) = V_i;
        tempV_test(i) = V_test_i;
        tempM(i, :) = M_i;
        tempM_test(i) = M_test_i;
        tempS(i, :) = S_i;
        tempS_test(i) = S_test_i;
        tempR(i, :) = R_i;
        tempR_test(i) = R_test_i;
    end

    % Assign temporary arrays to the main arrays
    V(idx, :, :) = tempV;
    V_test(idx, :) = tempV_test;
    M(idx, :, :) = tempM;
    M_test(idx, :) = tempM_test;
    S(idx, :, :) = tempS;
    S_test(idx, :) = tempS_test;
    R(idx, :, :) = tempR;
    R_test(idx, :) = tempR_test;
end

%% visulaisation
% figure;
% 
% -> filt_idx = 0: LPF 40 Hz and Notch
%                   -> filt_idx = 1: filter 0 + delta band
%                   -> filt_idx = 2: filter 0 + theta band
%                   -> filt_idx = 3: filter 0 + alpha band
%                   -> filt_idx = 4: filter 0 + beta band
% Create a figure to hold all subplots
figure (1);

% Define a grid for subplots: 2 rows and 2 columns
ax1 = subplot(2,2,1);
createConditionalBarChart(ax1, V(:,1), V_test(:,1), 'Bar Chart of V (delta)');

ax2 = subplot(2,2,2);
createConditionalBarChart(ax2, M(:,1), M_test(:,1), 'Bar Chart of M (delta)');

ax3 = subplot(2,2,3);
createConditionalBarChart(ax3, S(:,1), S_test(:,1), 'Bar Chart of S (delta)');

ax4 = subplot(2,2,4);
createConditionalBarChart(ax4, R(:,1), R_test(:,1), 'Bar Chart of R (delta)');

% Enhance spacing between subplots
sgtitle('Analysis of Delta Band Across Different Measures'); % Super title for all subplots

figure (2);

% Define a grid for subplots: 2 rows and 2 columns
ax1 = subplot(2,2,1);
createConditionalBarChart(ax1, V(:,2), V_test(:,2), 'Bar Chart of V (theta)');

ax2 = subplot(2,2,2);
createConditionalBarChart(ax2, M(:,2), M_test(:,2), 'Bar Chart of M (theta)');

ax3 = subplot(2,2,3);
createConditionalBarChart(ax3, S(:,2), S_test(:,2), 'Bar Chart of S (theta)');

ax4 = subplot(2,2,4);
createConditionalBarChart(ax4, R(:,2), R_test(:,2), 'Bar Chart of R (theta)');
sgtitle('Analysis of Theta Band Across Different Measures'); % Super title for all subplots

figure (3);

% Define a grid for subplots: 2 rows and 2 columns
ax1 = subplot(2,2,1);
createConditionalBarChart(ax1, V(:,3), V_test(:,3), 'Bar Chart of V (alpha)');
ax2 = subplot(2,2,2);
createConditionalBarChart(ax2, M(:,3), M_test(:,3), 'Bar Chart of M (alpha)');
ax3 = subplot(2,2,3);
createConditionalBarChart(ax3, S(:,3), S_test(:,3), 'Bar Chart of S (alpha)');
ax4 = subplot(2,2,4);
createConditionalBarChart(ax4, R(:,3), R_test(:,3), 'Bar Chart of R (alpha)');

% Enhance spacing between subplots
sgtitle('Analysis of alpha Band Across Different Measures'); % Super title for all subplots


figure (4);

% Define a grid for subplots: 2 rows and 2 columns
ax1 = subplot(2,2,1);
createConditionalBarChart(ax1, V(:,4), V_test(:,4), 'Bar Chart of V (beta)');
ax2 = subplot(2,2,2);
createConditionalBarChart(ax2, M(:,4), M_test(:,4), 'Bar Chart of M (beta)');
ax3 = subplot(2,2,3);
createConditionalBarChart(ax3, S(:,4), S_test(:,4), 'Bar Chart of S (beta)');
ax4 = subplot(2,2,4);
createConditionalBarChart(ax4, R(:,4), R_test(:,4), 'Bar Chart of R (beta)');

% Enhance spacing between subplots
sgtitle('Analysis of beta Band Across Different Measures'); % Super title for all subplots