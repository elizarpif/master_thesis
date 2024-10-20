%% 
ASR_setParameters_Bern;
filt_idx=0;
Data = eegData(1:2,:);


Data = ASR_Filter(Data, fs, ParamFilter,1); % Input expected: 2x10240

% if filt_idx == 1 % delta band
%     delta=[0.5 4];
%     [B,A] = butter(3,2*delta./fs,'bandpass');
% elseif filt_idx == 2 % theta band
%     theta=[4 8];
%     [B,A] = butter(3,2*theta./fs,'bandpass');
% elseif filt_idx == 3 % alpha band
%     alpha=[8 12];
%     [B,A] = butter(3,2*alpha./fs,'bandpass');
% elseif filt_idx == 4 % beta band
%     beta=[12 31];
%     [B,A] = butter(3,2*beta./fs,'bandpass');
% end
% 
% if filt_idx ~= 0 % if we want to filter to some band
%     filt = filtfilt(B,A,Data'); Data = filt';
% end
% [V_i, V_test_i, M_i, M_test_i, S_i, S_test_i, R_i, R_test_i] = EA_EEG_Main(currentArray, 0);

% fnyquist = 256.160664;
% fs = fnyquist * 2;
% ts = 1 / fs;
% 
% % New sampling and Nyquist frequencies
% fnyquist_new = fnyquist / 2;
% fs_new = fnyquist_new * 2;
% 
% % Bandpass filter design
% bpFilter = designfilt('bandpassiir', 'FilterOrder', 8, ...
%     'HalfPowerFrequency1', 0.5, 'HalfPowerFrequency2', 150, ...
%     'SampleRate', fs);
% 
% % Low-pass filter design
% lpFilter = designfilt('lowpassiir', 'FilterOrder', 8, ...
%     'HalfPowerFrequency', 40, 'SampleRate', fs);
% 
% % Notch filter design
% notchFilter = designfilt('bandstopiir', 'FilterOrder', 8, ...
%     'HalfPowerFrequency1', 49.8, 'HalfPowerFrequency2', 50.2, ...
%     'SampleRate', fs, 'DesignMethod', 'butter');
% 
% 
% 
%     channelData = eegData(1,1:150/ts);
% 
%     % Apply bandpass filter
%     channelData = filtfilt(bpFilter, channelData);
% 
%     % Apply low-pass filter
%     channelData = filtfilt(lpFilter, channelData);
% 
%     % Apply notch filter
%     channelData = filtfilt(notchFilter, channelData);
% 
% 
figure(1); 
[p, f] = periodogram(Data(1,:));
plot(f * fs / (2*pi), 10*log10(p));
title('periodogram');
xlabel('Frequency (Hz)')
ylabel('Power/frequency (dB/(rad/sample))');