function Rmetric = computeRMetric(data)
% Computes the R metric using EA_MeanPhaseCoherence
Rmetric = EA_MeanPhaseCoherence(data');
end