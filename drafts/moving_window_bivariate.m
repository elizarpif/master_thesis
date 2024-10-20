data = load("EEG3.mat");

eegData = data.EEG';
channelNameArray = data.channelNameArray;
% 
ASR_setParameters_Bern;

% ii) Parameters of surrogates
ParamSurro.Number = 19;        % Number of surrogates
ParamSurro.MaxIter = 120;      % Maximal Iterations
ParamSurro.type = 1;           % 1: perfect amplitudes, 2: perfect periodogram


% i) Pre-filtering of LPF 40 Hz + Notch or bands

numSignals = size(eegData, 1); % Total number of signals
numSamples = 10240; % Number of samples per segment
numSegments = floor(size(eegData, 2) / numSamples);
numSurroPlusOne = ParamSurro.Number + 1;

numPairs = numSignals / 2;  
allData = cell(numPairs, 1);

% Initialize the structure with further nested cells for each pair
for i = 1:numPairs
    allData{i} = cell(numSegments, 1);
    for j = 1:numSegments
        allData{i}{j} = cell(numSurroPlusOne, 1);  % Each segment holds original + surrogates
    end
end

parfor i = 1:numPairs
    for j = 1:numSegments
        % Determine the segment range
        startIndex = (j - 1) * numSamples + 1;
        endIndex = j * numSamples;

        % Filter the segments for both signals in the pair
        signalIndex1 = 2 * i - 1;  % First signal in the pair
        signalIndex2 = 2 * i;      % Second signal in the pair
        originalData1 = ASR_Filter(eegData(signalIndex1, startIndex:endIndex), fs, ParamFilter, 1);
        originalData2 = ASR_Filter(eegData(signalIndex2, startIndex:endIndex), fs, ParamFilter, 1);
        originalData = [originalData1; originalData2];  % Combine into a 2D vector

        % Store the original data in the first cell of the segment
        allData{i}{j}{1} = originalData;

        % Generate and store surrogates
        for k = 2:numSurroPlusOne
            surrogateData = ASR_SurrogateMulti(originalData, ParamSurro);  % Assume this function can handle 2D data
            allData{i}{j}{k} = surrogateData;
        end
    end
end


r_windows_mean_all = zeros(length(allData),length(allData{1}));
r_windows_test_all = zeros(length(allData),length(allData{1}));
r_windows_orig_all = zeros(length(allData),length(allData{1}));

for i=1:length(allData)
    % means of surrogates
    r_windows_mean = zeros(length(allData{i}),1);

    % tests
    r_windows_test = zeros(length(allData{i}),1);

    % original signal values
    r_windows_orig = zeros(length(allData{i}),1);

    for j=1:length(allData{i}) % 26 windows

        r = zeros(length(allData{i}{j})-1,1);

        for k=1:length(allData{i}{j}) % 20 surr
            [R] = EA_MeanPhaseCoherence(allData{i}{j}{k}); % 10240 samples
            if k == 1
                r_windows_orig(j) = R;
            else
                r(k-1) = R;
            end
        end

        % Tests
        if r_windows_orig(j) < min(r(:))
            r_windows_test(j,:) = 1;
        end

        % Means of surrogates
        r_windows_mean(j,:) = mean(r);
    end

    r_windows_mean_all(i,:) = r_windows_mean;
    r_windows_test_all(i,:) = r_windows_test;
    r_windows_orig_all(i,:) = r_windows_orig;

end


% Plot results
figure(1);
imagesc(r_windows_orig_all);
title('R, results');
colorbar;

% Set the tick marks and apply the string labels
numLabels = length(selectedChannelNames);
% xticks(1:numLabels); % Set x-ticks to match the number of labels
% xticklabels(selectedChannelNames); % Apply the x-axis labels
yticks(1:numLabels); % Set y-ticks to match the number of labels
yticklabels(selectedChannelNames); % Apply the y-axis labels

% Optionally, rotate the x-axis labels for better readability
% xtickangle(45); % Rotate x-axis labels by 45 degrees

% figure (2);

% Define a grid for subplots: 2 rows and 2 columns
% ax1 = subplot(2,2,1);
% createConditionalBarChart(ax1, V_results(1,:), V_test_results(1,:), 'Bar Chart of V');
%
% ax2 = subplot(2,2,2);
% createConditionalBarChart(ax2, M_results(1,:), M_test_results(1,:), 'Bar Chart of M');
%
% ax3 = subplot(2,2,3);
% createConditionalBarChart(ax3, S_results(1,:), S_test_results(1,:), 'Bar Chart of S');

% ax4 = subplot(2,2,4);
% createConditionalBarChart(ax4, R_results(1,:), R_test_results(1,:), 'Bar Chart of R');

% Enhance spacing between subplots
% sgtitle('Analysis of Delta Band Across Different Measures'); % Super title for all subplots
