function Rmetric = computeRMetric(data)
% Computes the R metric using EA_MeanPhaseCoherence
% data in 2xN
if size(data, 1) ~= 2
    data = data';
end

Rmetric = EA_MeanPhaseCoherence(data);
end