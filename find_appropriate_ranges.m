
% Define the root directory containing the dataset
rootDir = 'bern dataset/100 seizures';

% Get list of all patients (subdirectories in the dataset folder)
patients = dir(fullfile(rootDir, 'Pat*'));

m_values = 1:40;
l = 1;
r = 20*512;
k = 5;
theiler_correction = 30;
tau = 8;

%% parallel workers setup
% poolObj = gcp('nocreate'); % Get the current pool without creating a new one
% if isempty(poolObj)
%     poolObj = parpool; % If no pool, start the default pool
% end
% numWorkers = poolObj.NumWorkers;
% fprintf('Number of workers in the current pool: %d\n', numWorkers);

%%
% Initialize a cell array to store metrics for each patient and file
% metricsData = cell(length(m_values), 1);
colors = lines(length(patients));
figure;

seizuresToCheckForPatient=3;

%% Loop through each patient folder
for i = 1:length(patients)
    patientDir = fullfile(rootDir, patients(i).name);

    % Get list of all .mat files in the patient directory
    matFiles = dir(fullfile(patientDir, '*_block37.mat'));

    % Loop through each .mat file
    for j = 1:length(matFiles)
        if (j > seizuresToCheckForPatient)
            break
        end

        matFilePath = fullfile(patientDir, matFiles(j).name);

        % Load the .mat file
        data = load(matFilePath);

        eegData = data.EEG';
        channelNameArray = data.channelNameArray;

        datarec = eegData(1:2, l:r);
        datarec = datarec';

        % m=1 to m=50
        L_values = zeros(length(m_values),1);

        tic
        for m = 1:length(m_values)
            fprintf("m=%d\n", m);
            res = HSLMNCom(datarec,m,tau,k,theiler_correction);
            % save only L(X|Y)
            L_values(m) = res(2,2);
            fprintf("m=%d L=%f\n", m, L_values(m));
        end
        toc
        % Store L_values for this file in metricsData
        % metricsData{end + 1} = L_values;

        % Plot the curve for this file
        plot(m_values, L_values, 'DisplayName', sprintf('%s - %s', patients(i).name, matFiles(j).name));
        hold on;
    end
end

%% Customize the plot
xlabel('m value');
ylabel('L metric');
title('Comparison of L metric across files');
legend('show');
grid on;
hold off;

%% compute L for a range of m for a certain pair
% data = load("bern dataset/100 seizures/Pat16/P16_Sz1_block37.mat");
%
% eegData = data.EEG';
% channelNameArray = data.channelNameArray;
%
% l = 1;
% r = 20*512;
%
% % alpha = 0.001;
% k = 5;
% theiler_correction = 30;
% tau = 8;
%
% last_L = 0;
%
% for embedding_dim = 1:50
%
%     datarec = eegData(5:6, l:r);
%     datarec = datarec';
%
%     res = HSLMNCom(datarec,embedding_dim,tau,k,theiler_correction);
%     L = res(2,:);
%
%     if abs(last_L - L(1)) <= alpha
%         fprintf("FOUND! embedding dim = %d, L=%f, last_res = %f \n", embedding_dim, L(1), embedding_dim);
%         break
%     end
%
%     fprintf("embedding dim = %d, L=%f, last_res = %f \n", embedding_dim, L(1), last_L)
%     last_L = L(1);
% end


%% compute L for all pairs from one EEG with 2 fixed m (=8, =46)
% pairLen = size(eegData,1)/2;
%
% L_embedding1 = zeros(pairLen);
% L_embedding2 = zeros(pairLen);
%
% for i = 1:pairLen
%
%     datarec = eegData(i*2-1:i*2,l:r);
%     datarec = datarec';
%
%     embedding_dim = 46;
%     res = HSLMNCom(datarec,embedding_dim,tau,k,theiler_correction);
%     L = res(2,:);
%     fprintf("pair %d for m=%d L(1) = %f\n", i, embedding_dim, L(1));
%     L_embedding1(i) = L(1);
%
%     embedding_dim = 8;
%     res = HSLMNCom(datarec,embedding_dim,tau,k,theiler_correction);
%     L = res(2,:);
%     fprintf("pair %d for m=%d L(1) = %f\n", i,embedding_dim, L(1));
%     L_embedding2(i) = L(1);
% end
