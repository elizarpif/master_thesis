function Lmetric = computeLMetric(data)
% Computes the L metric using HSLMNCom
% data in (N*,2)
if size(data, 2) ~= 2
    data = data';
end

m = 8;
tau = 4;
k = 5;
theiler_correction = 50;
res = HSLMNCom(data, m, tau, k, theiler_correction);
Lmetric = res(2,:);
end
