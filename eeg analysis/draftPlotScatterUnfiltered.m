file = load('pat1_1_all_results_unfiltered.mat');
L_selected = file.L_XY_all;
R_selected = file.R_all;

colorbarMin = min([min(L_selected(:)), min(L_selected(:))]);
colorbarMax = max([max(L_selected(:)), max(L_selected(:))]);


eegImagescResult(file.timePointNames, file.R_all, file.numPairs, ...
 file.percentEndSeizureLocation, sprintf("R"), ...
    file.selectedPairNames, colorbarMin, colorbarMax)

wantPair = "";
wantTimeIntervalEnd = "";
paint = false;
% plotScatter(L_selected, R_selected, file.selectedPairNames, file.timePointNames, wantPair, wantTimeIntervalEnd, paint)

plotScatterDBSCAN(L_selected, R_selected, file.selectedPairNames)
