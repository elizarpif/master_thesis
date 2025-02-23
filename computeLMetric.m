function Lmetric = computeLMetric(data, downsamplingFactor)
% Computes the L metric using HSLMNCom
% data in (N*,2)
if size(data, 2) ~= 2
    data = data';
end

m = 8;
tau = 8; 
k = 5;
theiler_correction = 50;

if downsamplingFactor ~= 1 
    % downsamplingFactor=2, tau = 4, theiler = 25
    % downsamplingFactor=4, tau = 2, theiler = 12
    tau = tau/downsamplingFactor; 
    theiler_correction = floor(theiler_correction/downsamplingFactor);
end

res = HSLMNCom(data, m, tau, k, theiler_correction);
Lmetric = res(2,:);
end
