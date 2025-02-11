% Load data from file
data = load("bern dataset/100 seizures/Pat16/P16_Sz1_block37.mat");
eegDataOriginal = data.EEG';

% Define sampling frequency and time vector
Fs = 512; % Sampling frequency (Hz)

% figure;
% [pxx, f] = periodogram(eegDataOriginal(5,1:10240*9), [], [], Fs);
% plot(f, 10*log10(pxx), 'b'); 
% title('Periodogram - Original (512 Hz)');
% xlabel('Frequency (Hz)');
% ylabel('Power (dB/Hz)');
% grid on;

% Channel information
sample = eegDataOriginal(1:2, 10240*9:10240*10-1);
numChannels = 2;

downsampledBy2 = downsampleEEGData(sample, numChannels, Fs, 2);
downsampledBy4 = downsampleEEGData(sample, numChannels, Fs, 4);



% Define new sampling frequencies after downsampling
Fs2 = Fs / 2; % 256 Hz
Fs4 = Fs / 4; % 128 Hz




% % Compute and plot periodograms
% figure;
% 
% % Original signal (512 Hz)
% subplot(3,1,1);
% [pxx, f] = periodogram(sample(1,:), [], [], Fs);
% f_norm = f / (Fs/2);  % Normalize by Nyquist frequency
% plot(f_norm, 10*log10(pxx), 'b'); 
% title('Normalized Periodogram - Original (512 Hz)');
% xlabel('Normalized Frequency (× Nyquist)');
% ylabel('Power (dB/Hz)');
% grid on;
% xlim([0 1]);  % Normalized frequency range [0,1]
% 
% % Downsampled by 2 (256 Hz)
% subplot(3,1,2);
% [pxx, f] = periodogram(downsampledBy2(1,:), [], [], Fs2);
% f_norm = f / (Fs2/2);
% plot(f_norm, 10*log10(pxx), 'r'); 
% title('Normalized Periodogram - Downsampled by 2 (256 Hz)');
% xlabel('Normalized Frequency (× Nyquist)');
% ylabel('Power (dB/Hz)');
% grid on;
% xlim([0 1]);
% 
% % Downsampled by 4 (128 Hz)
% subplot(3,1,3);
% [pxx, f] = periodogram(downsampledBy4(1,:), [], [], Fs4);
% f_norm = f / (Fs4/2);
% plot(f_norm, 10*log10(pxx), 'g'); 
% title('Normalized Periodogram - Downsampled by 4 (128 Hz)');
% xlabel('Normalized Frequency (× Nyquist)');
% ylabel('Power (dB/Hz)');
% grid on;
% xlim([0 1]);
% 
% % Adjust layout
% sgtitle('Normalized Power Spectrum Comparison (Periodogram)');

% Original signal
% subplot(3,1,1);
% [pxx, f] = periodogram(sample(1,:), [], [], Fs);
% plot(f, 10*log10(pxx), 'b'); 
% title('Periodogram - Original (512 Hz)');
% xlabel('Frequency (Hz)');
% ylabel('Power (dB/Hz)');
% grid on;
% xlim([0 60]); % Focus on relevant frequency range
% 
% % Downsampled by 2 (256 Hz)
% subplot(3,1,2);
% [pxx, f] = periodogram(downsampledBy2(1,:), [], [], Fs2);
% plot(f, 10*log10(pxx), 'b'); 
% title('Periodogram - Downsampled by 2 (256 Hz)');
% xlabel('Frequency (Hz)');
% ylabel('Power (dB/Hz)');
% grid on;
% xlim([0 60]);
% 
% % Downsampled by 4 (128 Hz)
% subplot(3,1,3);
% [pxx, f] = periodogram(downsampledBy4(1,:), [], [], Fs4);
% plot(f, 10*log10(pxx), 'b'); 
% title('Periodogram - Downsampled by 4 (128 Hz)');
% xlabel('Frequency (Hz)');
% ylabel('Power (dB/Hz)');
% grid on;
% xlim([0 60]);


% check power frequency
% PlotEEG(sample, data.channelNameArray(1:2), Fs, "original");
% % PlotEEG(downsampledBy4, data.channelNameArray(1:2), Fs/4, "downsampled 4");
% 
% L = computeLMetric(sample');
% R = computeRMetric(sample');
% 
% L_2 = computeLMetric(sample');
% R_2 = computeRMetric(sample');
% 
% L4 = computeLMetric(downsampledBy4');
% R4 = computeRMetric(downsampledBy4');
% 
% L2 = computeLMetric(downsampledBy2');
% R2 = computeRMetric(downsampledBy2');
