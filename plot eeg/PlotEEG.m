function PlotEEG(eegData, channelNameArray, title )
eegDataT = eegData.';

% sampling frequency; data is sampled at 512 Hz
Fs = 512;
total_duration = length(eegDataT(1,:))/Fs;
Ts = 1/Fs;
time_vector = 0:Ts:total_duration;

global amplitude_parameter;
amplitude_parameter = 10; % Initial value

% visualise the data
keypressPlot(time_vector(1:length(eegData)),eegDataT(:,:),channelNameArray(:), title);

end