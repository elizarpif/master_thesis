data = load("EEG3.mat");

eegData = data.EEG';
channelNameArray = data.channelNameArray;

ASR_setParameters_Bern;

% ii) Parameters of surrogates
ParamSurro.Number = 19;        % Number of surrogates
ParamSurro.MaxIter = 120;      % Maximal Iterations
ParamSurro.type = 1;           % 1: perfect amplitudes, 2: perfect periodogram
filt_idx=0;

% i) Pre-filtering of LPF 40 Hz + Notch or bands

numSignals = size(eegData, 1); % Total number of signals
numSamples = 10240; % Number of samples per segment
numSegments = floor(size(eegData, 2) / numSamples); % Number of segments per signal
numSurroPlusOne = ParamSurro.Number + 1; % Including the original

% Cell array to store all data
allData = cell(numSignals, 1);

% Initialize the structure with further nested cells
for i = 1:numSignals
    allData{i} = cell(numSegments, 1);

    for j = 1:numSegments
        allData{i}{j} = cell(numSurroPlusOne, 1); % Each segment will hold original + surrogates
    end
end

if filt_idx == 1 % delta band
    delta=[0.5 4];
    [B,A] = butter(3,2*delta./fs,'bandpass');
elseif filt_idx == 2 % theta band
    theta=[4 8];
    [B,A] = butter(3,2*theta./fs,'bandpass');
elseif filt_idx == 3 % alpha band
    alpha=[8 12];
    [B,A] = butter(3,2*alpha./fs,'bandpass');
elseif filt_idx == 4 % beta band
    beta=[12 31];
    [B,A] = butter(3,2*beta./fs,'bandpass');
end

parfor i = 1:numSignals
    for j = 1:numSegments
        % Determine the segment range
        startIndex = (j - 1) * numSamples + 1;
        endIndex = j * numSamples;

        % Filter the segment
        originalData = ASR_Filter(eegData(i, startIndex:endIndex), fs, ParamFilter, 1);

        if filt_idx ~= 0 % if we want to filter to some band
            filt = filtfilt(B,A,originalData'); originalData = filt';
        end

        % Store the original data in the first cell of the segment
        allData{i}{j}{1} = originalData;

        % Generate and store surrogates
        for k = 2:numSurroPlusOne
            surrogateData = ASR_SurrogateUni(originalData, ParamSurro);
            allData{i}{j}{k} = surrogateData;
        end
    end
end

m_windows_mean_all = zeros(length(allData),length(allData{1}));
s_windows_mean_all = zeros(length(allData),length(allData{1}));
v_windows_mean_all = zeros(length(allData),length(allData{1}));

m_windows_test_all = zeros(length(allData),length(allData{1}));
s_windows_test_all = zeros(length(allData),length(allData{1}));
v_windows_test_all = zeros(length(allData),length(allData{1}));

m_windows_orig_all = zeros(length(allData),length(allData{1}));
s_windows_orig_all = zeros(length(allData),length(allData{1}));
v_windows_orig_all = zeros(length(allData),length(allData{1}));

for i=1:length(allData)
    % means of surrogates
    m_windows_mean = zeros(length(allData{i}),1);
    s_windows_mean = zeros(length(allData{i}),1);
    v_windows_mean = zeros(length(allData{i}),1);

    % tests
    m_windows_test = zeros(length(allData{i}),1);
    s_windows_test = zeros(length(allData{i}),1);
    v_windows_test = zeros(length(allData{i}),1);

    % original signal values
    m_windows_orig = zeros(length(allData{i}),1);
    s_windows_orig = zeros(length(allData{i}),1);
    v_windows_orig = zeros(length(allData{i}),1);


    for j=1:length(allData{i}) % 26 windows

        m = zeros(length(allData{i}{j})-1,1);
        v = zeros(length(allData{i}{j})-1,1);
        s = zeros(length(allData{i}{j})-1,1);

        for k=1:length(allData{i}{j}) % 20 surr
            [V, M, S] = EA_CoefPhaseVelVar(allData{i}{j}{k}); % 10240 samples
            if k == 1
                m_windows_orig(j) = M;
                s_windows_orig(j) = S;
                v_windows_orig(j) = V;
            else
                m(k-1) = M;
                s(k-1) = S;
                v(k-1) = V;
            end
        end

        % Tests
        if v_windows_orig(j) < min(v(:))
            v_windows_test(j,:) = 1;
        end

        if s_windows_orig(j) < min(s(:))
            s_windows_test(j,:) = 1;
        end

        if m_windows_orig(j) < min(m(:))
            m_windows_test(j,:) = 1;
        end

        % Means of surrogates
        m_windows_mean(j,:) = mean(m);
        s_windows_mean(j,:) = mean(s);
        v_windows_mean(j,:) = mean(v);
    end

    m_windows_mean_all(i,:) = m_windows_mean;
    v_windows_mean_all(i,:) = v_windows_mean;
    s_windows_mean_all(i,:) = s_windows_mean;

    m_windows_test_all(i,:) = m_windows_test;
    v_windows_test_all(i,:) = v_windows_test;
    s_windows_test_all(i,:) = s_windows_test;

    m_windows_orig_all(i,:) = m_windows_orig;
    v_windows_orig_all(i,:) = v_windows_orig;
    s_windows_orig_all(i,:) = s_windows_orig;


end


% Plot results
figure(1);
imagesc(m_windows_test_all);
title('M, tests');
colorbar;

% Set the tick marks and apply the string labels
numLabels = length(selectedChannelNames);
% xticks(1:numLabels); % Set x-ticks to match the number of labels
% xticklabels(selectedChannelNames); % Apply the x-axis labels
yticks(1:numLabels); % Set y-ticks to match the number of labels
yticklabels(selectedChannelNames); % Apply the y-axis labels


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
