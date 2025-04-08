function noisy_signal = add_measurement_noise(noise_case, original_signal, desired_SNR)
% Define parameters
N = 1024;  % Number of noise samples

if noise_case == "NOISE ONLY"
    noisy_signal = randn(1, N);
    return;
end
if noise_case == "NO NOISE"
    noisy_signal = original_signal;
    return;
end

% Generate zero-mean unit-variance Gaussian white noise
noiseStd = std(original_signal)/desired_SNR;

original_noise = randn(1, N);
modified_noise = original_noise * noiseStd;

noisy_signal = original_signal + modified_noise;
end