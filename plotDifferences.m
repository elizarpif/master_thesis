% load('pat16_part1_results.mat');

% % % % 

bands = ["\alpha", "\beta", "\theta", "\delta"];

% Compute colorbar limits dynamically (including both L and R values)
colorbarMin = min([L_XY_all(:); R_all(:)]);
colorbarMax = max([L_XY_all(:); R_all(:)]);

% === Define band comparisons ===
comparisons = [3, 1; 1, 2]; % [theta-alpha; alpha-beta]

for i = 1:size(comparisons, 1)
    band1 = comparisons(i, 1);
    band2 = comparisons(i, 2);
    
    diffMask = abs(L_XY_all(band1, :, :) - L_XY_all(band2, :, :)) > 0.3;
    
    eegImagescResultMask(timePointNames, squeeze(L_XY_all(band1, :, :)), numPairs, ...
        percentEndSeizureLocation, sprintf("L_{%s} (X|Y) (%s vs %s)", bands(band1), bands(band1), bands(band2)), ...
        selectedPairNames, squeeze(diffMask), colorbarMin, colorbarMax);

    eegImagescResultMask(timePointNames, squeeze(L_XY_all(band2, :, :)), numPairs, ...
        percentEndSeizureLocation, sprintf("L_{%s} (X|Y) (%s vs %s)", bands(band2), bands(band1), bands(band2)), ...
        selectedPairNames, squeeze(diffMask), colorbarMin, colorbarMax);

end

% === Compare L and R metrics within the same band ===
for bandIndex = 2
    diffMask = abs(L_XY_all(bandIndex, :, :) - R_all(bandIndex, :, :)) > 0.3;
    if bandIndex == 4
        diffMask = abs(L_XY_all(bandIndex, :, :) - R_all(bandIndex, :, :)) > 0.4;
    end

    eegImagescResultMask(timePointNames, squeeze(L_XY_all(bandIndex, :, :)), numPairs, ...
        percentEndSeizureLocation, sprintf("L_{XY} (vs R) (%s)", bands(bandIndex)), ...
        selectedPairNames, squeeze(diffMask), colorbarMin, colorbarMax);
    
    eegImagescResultMask(timePointNames, squeeze(R_all(bandIndex, :, :)), numPairs, ...
        percentEndSeizureLocation, sprintf("R (vs L_{XY}) (%s)", bands(bandIndex)), ...
        selectedPairNames, squeeze(diffMask), colorbarMin, colorbarMax);
end
