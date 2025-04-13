patNum = 1;
partNum = 1;

data = load(sprintf("dataset/100 seizures/Pat%d/P0%d_Sz%d_block37.mat", patNum,patNum, partNum));
eegDataOriginal = data.EEG';

Fs = 512; 
total_duration = length(eegDataOriginal(1, :)) / Fs;
Ts = 1 / Fs; 

filteredEEGbyBand = eegDataOriginal;

% filteredEEGbyBand = filterAllEEGByBand(eegDataOriginal, Fs, "delta");
PlotEEG(filteredEEGbyBand, data.channelNameArray, Fs, sprintf("pat %d, part %d", patNum, partNum));


% figure;
% [pxx, f] = periodogram(eegDataOriginal(38,:), [], [], Fs);
% plot(f, 10*log10(pxx), 'b'); 
% title('Periodogram');
% xlabel('Frequency (Hz)');
% ylabel('Power (dB/Hz)');
% grid on;