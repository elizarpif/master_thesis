% % [**] The data as provided on the page is sampled at 512 HZ and band-pass
% % filtered between 0.5Hz and 150Hz. As described in the manuscript, we
% % applied an additional low-pass Butterworth-filter with a cut-off frequency
% % of 40Hz. Furthermore, we applied a stop-band filter between 46.5HZ and
% % 53.5Hz to supress 50Hz line noise. Note however, that this stop-band
% % filter has almost no effect, since the filter function the low-pass at 40Hz 
% % already very small at 50Hz. So, the low-pass already supresses the line
% % noise.
% % Important note: this filtering is the first step of analysis, and the type of
% % pre-processing should be adjusted to the specific type of data under
% % analysis.
% 
data = load("EEG3.mat");

eegData = data.EEG';
channelNameArray = data.channelNameArray;
% 
% % % utility frequency is 50 Hz
%% FILTER BEFORE ANALYSIS
fnyquist = 256;
fs = fnyquist * 2;
ts = 1 / fs;
% 
% % New sampling and Nyquist frequencies
% fnyquist_new = fnyquist / 2;
% fs_new = fnyquist_new * 2;
% 
numChannels = 64;  % Number of EEG channels
filteredEEGData = zeros(numChannels,10240);  % Preallocate matrix for filtered and downsampled data

for i = 1:numChannels
    % Extract channel data
    channelData = eegData(i,179200:189440);

    % Store in matrix
    filteredEEGData(i, :) = channelData;
end

% figure;
% plot(eegData(1,:));  % Plot original data of first channel
% hold on;
% plot(filteredEEGData(1,:), 'r');  % Plot filtered data
% legend('Original', 'Filtered');
% xlabel('Samples');
% ylabel('Amplitude');
% title('EEG Channel 1');

numPairs = floor(size(filteredEEGData, 1) / 2);  % Compute the number of pairs
selectedPairs = cell(1, numPairs);  % Preallocate the cell array to improve performance

for idx = 1:numPairs
    eegIdx = 2 * idx - 1;  % Compute the start index for the pair
    pair = filteredEEGData(eegIdx:eegIdx + 1, :, :);  % Extract the pair
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
numColumns = 20;  % Example number of columns per matrix (1+19 surr)
% bands = {'delta', 'theta', 'alpha', 'beta'};
% numBands = length(bands);

% Define outside the parfor to avoid broadcasting large structures if possible

% Initialize matrices outside of parfor for clarity
V_seiz = zeros(numPairs, 20);
V_seiz_test = zeros(numPairs,  1);
M_seiz = zeros(numPairs, 20);
M_seiz_test = zeros(numPairs, 1);
S_seiz = zeros(numPairs, 20);
S_seiz_test = zeros(numPairs, 1);
R_seiz = zeros(numPairs, 20);
R_seiz_test = zeros(numPairs,1);

parfor idx = 1:length(selectedPairs)
    currentArray = selectedPairs{idx};  % Access pre-sliced data for current pair
    channelName = selectedPairNames{idx}  % Access the corresponding channel name
% disp(channelName)
    % Temporary arrays to collect data within loop to avoid slicing issues
    % tempV = zeros(numBands, 20);
    % tempV_test = zeros(numBands, 1);
    % tempM = zeros(numBands, 20);
    % tempM_test = zeros(numBands, 1);
    % tempS = zeros(numBands, 20);
    % tempS_test = zeros(numBands, 1);
    % tempR = zeros(numBands, 20);
    % tempR_test = zeros(numBands, 1);

    % for i = 1:numBands
        [V_i, V_test_i, M_i, M_test_i, S_i, S_test_i, R_i, R_test_i] = EA_EEG_Main(currentArray, 0);

        % Store in temporary variables
        % tempV(i, :) = V_i;
        % tempV_test(i) = V_test_i;
        % tempM(i, :) = M_i;
        % tempM_test(i) = M_test_i;
        % tempS(i, :) = S_i;
        % tempS_test(i) = S_test_i;
        % tempR(i, :) = R_i;
        % tempR_test(i) = R_test_i;
    % end

    % Assign temporary arrays to the main arrays
    V_seiz(idx, :) = V_i;
    V_seiz_test(idx, :) = V_test_i;
    M_seiz(idx, :) = M_i;
    M_seiz_test(idx, :) = M_test_i;
    S_seiz(idx, :) = S_i;
    S_seiz_test(idx, :) = S_test_i;
    R_seiz(idx, :) = R_i;
    R_seiz_test(idx, :) = R_test_i;
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
createConditionalBarChart(ax1, V_seiz(:,1), V_seiz_test, 'Bar Chart of V (notch)');

ax2 = subplot(2,2,2);
createConditionalBarChart(ax2, M_seiz(:,1), M_seiz_test, 'Bar Chart of M (notch)');

ax3 = subplot(2,2,3);
createConditionalBarChart(ax3, S_seiz(:,1), S_seiz_test, 'Bar Chart of S (notch)');

ax4 = subplot(2,2,4);
createConditionalBarChart(ax4, R_seiz(:,1), R_seiz_test, 'Bar Chart of R (notch)');

% Enhance spacing between subplots
sgtitle('Solo DEL electrode'); % Super title for all subplots

% figure (2);
% 
% % Define a grid for subplots: 2 rows and 2 columns
% ax1 = subplot(2,2,1);
% createConditionalBarChart(ax1, V(:,2), V_test(:,2), 'Bar Chart of V (theta)');
% 
% ax2 = subplot(2,2,2);
% createConditionalBarChart(ax2, M(:,2), M_test(:,2), 'Bar Chart of M (theta)');
% 
% ax3 = subplot(2,2,3);
% createConditionalBarChart(ax3, S(:,2), S_test(:,2), 'Bar Chart of S (theta)');
% 
% ax4 = subplot(2,2,4);
% createConditionalBarChart(ax4, R(:,2), R_test(:,2), 'Bar Chart of R (theta)');
% sgtitle('Analysis of Theta Band Across Different Measures'); % Super title for all subplots
% 
% figure (3);
% 
% % Define a grid for subplots: 2 rows and 2 columns
% ax1 = subplot(2,2,1);
% createConditionalBarChart(ax1, V(:,3), V_test(:,3), 'Bar Chart of V (alpha)');
% ax2 = subplot(2,2,2);
% createConditionalBarChart(ax2, M(:,3), M_test(:,3), 'Bar Chart of M (alpha)');
% ax3 = subplot(2,2,3);
% createConditionalBarChart(ax3, S(:,3), S_test(:,3), 'Bar Chart of S (alpha)');
% ax4 = subplot(2,2,4);
% createConditionalBarChart(ax4, R(:,3), R_test(:,3), 'Bar Chart of R (alpha)');
% 
% % Enhance spacing between subplots
% sgtitle('Analysis of alpha Band Across Different Measures'); % Super title for all subplots
% 
% 
% figure (4);
% 
% % Define a grid for subplots: 2 rows and 2 columns
% ax1 = subplot(2,2,1);
% createConditionalBarChart(ax1, V(:,4), V_test(:,4), 'Bar Chart of V (beta)');
% ax2 = subplot(2,2,2);
% createConditionalBarChart(ax2, M(:,4), M_test(:,4), 'Bar Chart of M (beta)');
% ax3 = subplot(2,2,3);
% createConditionalBarChart(ax3, S(:,4), S_test(:,4), 'Bar Chart of S (beta)');
% ax4 = subplot(2,2,4);
% createConditionalBarChart(ax4, R(:,4), R_test(:,4), 'Bar Chart of R (beta)');
% 
% % Enhance spacing between subplots
% sgtitle('Analysis of beta Band Across Different Measures'); % Super title for all subplots
% 
