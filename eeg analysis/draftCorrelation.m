corr_values = zeros(5, 1);

for bandIdx = 1:4
    L_selected = squeeze(L_XY_all(bandIdx,:,:));
    R_selected = squeeze(R_all(bandIdx,:,:));
    corr_matrix = corrcoef(L_selected(:), R_selected(:));
    corr_values(bandIdx) = corr_matrix(1, 2);
end

corr_matrix = corrcoef(L_XY_unfiltered(:), R_unfiltered(:));
corr_values(5) = corr_matrix(1, 2);
% Вывод корреляций по каждой паре
% disp('Корреляции по парам:');
% disp(corr_values);

% Визуализация корреляции по каждой паре
figure;
bar(corr_values);
xlabel('Band');
ylabel('Correllation (Pearson)');
title('Correllation between L и R for 4 bands + unfiltered');
set(gca, 'XTickLabel', ["alpha", "beta", "theta", "delta", "unfiltered"], 'XTick', 1:5); % Устанавливаем имена на ось X

% legend_labels = arrayfun(@(x) selectedPairNames(x), 1:num_pairs, 'UniformOutput', false);
% legend(legend_labels, 'Location', 'eastoutside'); % Move legend outside

grid on;
