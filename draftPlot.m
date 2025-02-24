data = load("bern dataset/100 seizures/Pat16/P16_Sz1_block37.mat");
eegDataOriginal = data.EEG';

Fs = 512; 
total_duration = length(eegDataOriginal(1, :)) / Fs;
Ts = 1 / Fs; 

filteredEEGbyBand = eegDataOriginal;

filteredEEGbyBand = filterAllEEGByBand(eegDataOriginal, Fs, "delta");
PlotEEG(filteredEEGbyBand, data.channelNameArray, Fs, sprintf("pat 16, part 1 (delta band)"));


% figure;
% [pxx, f] = periodogram(eegDataOriginal(38,:), [], [], Fs);
% plot(f, 10*log10(pxx), 'b'); 
% title('Periodogram');
% xlabel('Frequency (Hz)');
% ylabel('Power (dB/Hz)');
% grid on;