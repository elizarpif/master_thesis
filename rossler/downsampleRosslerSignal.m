function [x, t] = downsampleRosslerSignal(x_res, t, isPlotDynamics)
% in order to have approx 20 samples per cycle, downsample
ds_factor = 9;

% Downsample the x signal using the calculated rate
x_downsampled = x_res(1:ds_factor:end);
t_downsampled = t(1:ds_factor:end);

% and take only 10240 last samples
number_of_samples = 10240;
x = x_downsampled(end-number_of_samples+1: end);
t = t_downsampled(end-number_of_samples+1: end);

% Optional: Plot the downsampled signal
if isPlotDynamics
    figure;
    plot(t, x);
    title('Downsampled Signal');
    xlabel('Time [a.u.]');
    ylabel('Values');
    grid on;
end
end