
% Base folder for the Bern dataset
baseFolder = '/Users/elizavetapivovarova/Documents/eeg analysis/bern dataset/';
patientNum = 11;

for seiz = 1:2
    % Construct the folder name (e.g., Pat1, Pat2, ..., Pat16)
    patientFolder = sprintf('Pat%d', patientNum);

    % Construct the file name (e.g., P01_addInfo.mat, P02_addInfo.mat, ..., P16_addInfo.mat)
    if patientNum < 10
        fileName = sprintf('P0%d_Sz%d_block37.mat', patientNum, seiz); % Adds leading zero for P01 to P09
    else
        fileName = sprintf('P%d_Sz%d_block37.mat', patientNum, seiz);  % No leading zero for P10 to P16
    end

    % Full path to the .mat file
    fullFileName = fullfile(baseFolder, '100 seizures', patientFolder, fileName);

    % Check if the file exists
    if isfile(fullFileName)
        data = load(fullFileName);
        eegData = data.EEG;
        channelNameArray = data.channelNameArray;

        figure (seiz);
        PlotEEG(eegData, channelNameArray, sprintf("Patient%d", patientNum))

    else
        fprintf('File %s does not exist.\n', fullFileName);
    end
end
