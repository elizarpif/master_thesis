function Lmetric = computeLMetric(data)
% Computes the L metric using HSLMNCom
m = 8;
tau = 4;
k = 5;
theiler_correction = 50;
Lmetric = HSLMNCom(data, m, tau, k, theiler_correction);
end
