function noisy_signal = add_measurement_noise(original_signal, noise_level)
% Define parameters
N = 4096;  % Number of noise samples

% Generate zero-mean unit-variance Gaussian white noise
original_noise = randn(1, N);
modified_noise = original_noise * noise_level;
% for ex, if noise level = 1
% and std(original_noise) = 1
% and std(original_signal) = 17
% then snr = 17
% if I want snr = 1, I need std(modified_signal) = 17, then I need
% noise_level = 17

snr = std(original_signal)/std(modified_noise);

% disp(['snr: ', num2str(snr)]);

noisy_signal = original_signal + modified_noise;
