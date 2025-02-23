load('pat16_part1_results.mat');

% % % %

bands = ["alpha", "beta", "theta", "delta"];

% === Define band comparisons ===
comparisons = [3, 1; 1, 2]; % [theta-alpha; alpha-beta]

% for i = 1:size(comparisons, 1)
%     band1 = comparisons(i, 1);
%     band2 = comparisons(i, 2);
%     % 
%     % diffMask = abs(L_XY_all(band1, :, :) - L_XY_all(band2, :, :)) > 0.3;
%     % 
%     % 
%     % colorbarMin = min([L_XY_all(band1, :, :); L_XY_all(band2, :, :)]);
%     % colorbarMax = max([L_XY_all(band1, :, :); L_XY_all(band2, :, :)]);
% 
%     % eegImagescResultMask(timePointNames, squeeze(L_XY_all(band1, :, :)), numPairs, ...
%     %     percentEndSeizureLocation, sprintf("L_{\%s} (X|Y) (\%s vs \%s)", bands(band1), bands(band1), bands(band2)), ...
%     %     selectedPairNames, squeeze(diffMask), colorbarMin, colorbarMax);
%     %
%     % eegImagescResultMask(timePointNames, squeeze(L_XY_all(band2, :, :)), numPairs, ...
%     %     percentEndSeizureLocation, sprintf("L_{\%s} (X|Y) (\%s vs \%s)", bands(band2), bands(band1), bands(band2)), ...
%     %     selectedPairNames, squeeze(diffMask), colorbarMin, colorbarMax);
% 
%     diffMask = abs(R_all(band1, :, :) - R_all(band2, :, :)) > 0.3;
% 
%     R_band1 = squeeze(R_all(band1, :, :));
%     R_band2 = squeeze(R_all(band2, :, :));
% 
%     colorbarMin = min([min(R_band1(:)), min(R_band2(:))]);
%     colorbarMax = max([max(R_band1(:)), max(R_band2(:))]);
% 
%     fig = figure;
% 
%     eegImagescResultMask(timePointNames, R_band1, numPairs, ...
%         percentEndSeizureLocation, sprintf("R_{\\%s} (\\%s vs \\%s)", bands(band1), bands(band1), bands(band2)), ...
%         selectedPairNames, squeeze(diffMask), colorbarMin, colorbarMax);
% 
%     savefig(fig, sprintf('moving window analysis/pat16/R_%s_vs_%s.fig', bands(band1),bands(band2)));
%     saveas(fig, sprintf('moving window analysis/pat16/R_%s_vs_%s.jpg', bands(band1),bands(band2)));
% 
%     close(fig);
% 
%     fig = figure;
% 
%     eegImagescResultMask(timePointNames, R_band2, numPairs, ...
%         percentEndSeizureLocation, sprintf("R_{\\%s} (\\%s vs \\%s)", bands(band2), bands(band1), bands(band2)), ...
%         selectedPairNames, squeeze(diffMask), colorbarMin, colorbarMax);
% 
%     savefig(fig, sprintf('moving window analysis/pat16/R_%s_vs_%s.fig', bands(band2), bands(band1)));
%     saveas(fig, sprintf('moving window analysis/pat16/R_%s_vs_%s.jpg', bands(band2), bands(band1)));
% 
%     close(fig);
% end

% === Compare L and R metrics within the same band ===
for bandIndex = 4
    L_XY_band = squeeze(L_XY_all(bandIndex, :, :));
    R_all_band = squeeze(R_all(bandIndex, :, :));

    diffMask = abs(L_XY_band - R_all_band) > 0.3;
    if bandIndex == 4
        diffMask = abs(L_XY_band - R_all_band) > 0.4;
    end

    colorbarMin = min([min(L_XY_band(:)), min(R_all_band(:))]);
    colorbarMax = max([max(L_XY_band(:)), max(R_all_band(:))]);

    % eegImagescResultMask(timePointNames, L_XY_band, numPairs, ...
    %     percentEndSeizureLocation, sprintf("L_{XY} (vs R) (%s)", bands(bandIndex)), ...
    %     selectedPairNames, squeeze(diffMask), colorbarMin, colorbarMax);
    %
    % eegImagescResultMask(timePointNames, R_all_band, numPairs, ...
    %     percentEndSeizureLocation, sprintf("R (vs L_{XY}) (%s)", bands(bandIndex)), ...
    %     selectedPairNames, squeeze(diffMask), colorbarMin, colorbarMax);

    % fig = figure;
    %
    % eegImagescResult(timePointNames, L_XY_band, numPairs, ...
    %     percentEndSeizureLocation, sprintf("L_{XY} (\\%s)", bands(bandIndex)), ...
    %     selectedPairNames, colorbarMin, colorbarMax);
    %
    % savefig(fig, sprintf('moving window analysis/pat16/L_XY_%s.fig', bands(bandIndex)));
    % saveas(fig, sprintf('moving window analysis/pat16/L_XY_%s.jpg', bands(bandIndex)));
    %
    % close(fig);
    %
    % fig = figure;
    % eegImagescResult(timePointNames, R_all_band, numPairs, ...
    %     percentEndSeizureLocation, sprintf("R (\\%s)", bands(bandIndex)), ...
    %     selectedPairNames, colorbarMin, colorbarMax);
    %
    % savefig(fig, sprintf('moving window analysis/pat16/R_%s.fig', bands(bandIndex)));
    % saveas(fig, sprintf('moving window analysis/pat16/R_%s.jpg', bands(bandIndex)));
    %
    % close(fig);

end
