% data = load("bern dataset/100 seizures/Pat9/P09_Sz3_block37.mat");
% % data = load("example EEGs/EEG4.mat");
% eegData = data.EEG;
% channelNameArray = data.channelNameArray;
%
% figure (1);
% PlotEEG(eegData, channelNameArray)



for i = 13:16
    filePath = sprintf('bern dataset/100 seizures/Pat%d/P%d_Sz1_block37.mat', i, i);

    data = load(filePath);
    eegData = data.EEG;
    channelNameArray = data.channelNameArray;

    figure (i);
    PlotEEG(eegData, channelNameArray, sprintf("Patient%d", i))
end