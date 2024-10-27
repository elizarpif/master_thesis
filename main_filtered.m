data = load("bern dataset/100 seizures/Pat11/P11_Sz1_block37.mat");
% data = load("example EEGs/EEG4.mat");
eegData = data.EEG;
channelNameArray = data.channelNameArray;
% 
Fs = 512;  % Частота дискретизации (Hz), нужно заменить на вашу фактическую частоту
lowCutoff = 10;  % Нижняя частота среза для high-pass фильтра
highCutoff = 70; % Верхняя частота среза для low-pass фильтра

% Создание полосового фильтра Баттерворта для поиска спайков
[b, a] = butter(4, [lowCutoff highCutoff]/(Fs/2), 'bandpass');

% Применение фильтрации к данным ЭЭГ
filteredEEGData = filtfilt(b, a, eegData);
figure (2);
PlotEEG(filteredEEGData, channelNameArray)
