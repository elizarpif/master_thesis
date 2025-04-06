load('patients results/pat3_1_all_results_unfiltered.mat');

% bands = ["alpha", "beta", "theta", "delta"];
% selected_band = 4; % Select the frequency band (1: alpha, 2: beta, 3: theta, 4: delta)
% 
% L_selected = squeeze(L_XY_all(selected_band, :, :));
% R_selected = squeeze(R_all(selected_band, :, :));

L_selected = L_XY_all;
R_selected = R_all;

wantPair = "";
wantTimeIntervalEnd = "";
paint = true;

plotScatter(L_selected, R_selected, selectedPairNames, timePointNames, ...
    wantPair, wantTimeIntervalEnd, paint, ...
    "patients results/plotBySOZ_unfiltered.jpg", "unfiltered")

load('patients results/pat3_1_all_results_bands.mat');

bands = ["alpha", "beta", "theta", "delta"];
% selected_band = 4; % Select the frequency band (1: alpha, 2: beta, 3: theta, 4: delta)



for i = 1:length(bands)
    L_selected = squeeze(L_XY_all(i, :, :));
    R_selected = squeeze(R_all(i, :, :));

    filename = sprintf("patients results/plotBySOZ_%s.jpg", bands(i));
    plotScatter(L_selected, R_selected, selectedPairNames, timePointNames, ...
        wantPair, wantTimeIntervalEnd, paint, ...
        filename, bands(i));
end