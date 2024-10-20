
% Base folder for the Bern dataset
baseFolder = '/Users/elizavetapivovarova/Documents/eeg analysis/bern dataset/';

% Loop through patient numbers from 1 to 16
for patientNum = 1:16
    % Construct the folder name (e.g., Pat1, Pat2, ..., Pat16)
    patientFolder = sprintf('Pat%d', patientNum);
    
    % Construct the file name (e.g., P01_addInfo.mat, P02_addInfo.mat, ..., P16_addInfo.mat)
    if patientNum < 10
        fileName = sprintf('P0%d_syndrome.mat', patientNum); % Adds leading zero for P01 to P09
    else
        fileName = sprintf('P%d_syndrome.mat', patientNum);  % No leading zero for P10 to P16
    end
    
    % Full path to the .mat file
    fullFileName = fullfile(baseFolder, '100 seizures', patientFolder, fileName);
    
    % Check if the file exists
    if isfile(fullFileName)
        % Load the .mat file
        data = load(fullFileName);
        
        % Display the file name
        fprintf('Data from %s:\n', fileName);
        
        % Display the variables inside the file
        disp(data);
        
        % If you know the variable name inside the .mat file, you can access it like:
        % disp(data.variableName);
    else
        fprintf('File %s does not exist.\n', fullFileName);
    end
end
