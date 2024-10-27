data = load("bern dataset/100 seizures/Pat12/P12_Sz1_block37.mat");

% check power spectrum

eegData = data.EEG;
channelNameArray = data.channelNameArray;

eegDataT = eegData.';


% sampling frequency
Fs = 512; 
total_duration = length(eegDataT(1,:))/Fs;
Ts = 1/Fs; 
time_vector = 0:Ts:total_duration;

% total_duration / Ts = all_time_poitns

% Extract the EEG data for the specified time interval
eeg_data_interval = eegDataT(3, 42/Ts:46/Ts);

% Compute the power spectrum for the specified EEG data
% figure(2)
% periodogram(eeg_data_interval);

figure(2);
periodogram(eeg_data_interval, [], [], Fs);  % Use Fs to label frequency in Hz
xlabel('Frequency (Hz)');
ylabel('Power/Frequency (dB/Hz)');
title('Periodogram of EEG Data (42-46 seconds)');
