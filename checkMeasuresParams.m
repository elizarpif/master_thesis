% Load data from file
data = load("bern dataset/100 seizures/Pat16/P16_Sz1_block37.mat");
eegDataOriginal = data.EEG';

% Define sampling frequency and time vector
Fs = 512; % Sampling frequency (Hz)

% Channel information
sample = eegDataOriginal(1:2, 10240*9:10240*10-1);
downsampledBy4 = downsampleEEGData(sample, Fs, 4);

m = 8;
k = 5;
theiler_correction = 12;
tau = 4;

resultsL_XY = zeros(50, 1);

for k=1:100
    tic
    res = HSLMNCom(downsampledBy4', m, tau, k, theiler_correction);
    resultsL_XY(k) = res(2,1);
    logger(sprintf("computed k=%d",k));
    toc
end

% disp(['R: 512Hz -> 256Hz, difference = ', num2str(L-L2)]);
% disp(['L: 512Hz -> 256Hz, difference = ', num2str(R-R2)]);
figure;
plot(resultsL_XY);