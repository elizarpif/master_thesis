
num_pairs = 32;
num_windows = 22;

corr_values = zeros(num_pairs, 1);

for pair_idx = 1:num_pairs
    corr_matrix = corrcoef(L_selected(pair_idx, :), R_selected(pair_idx, :));
    corr_values(pair_idx) = corr_matrix(1, 2);
end

% Вывод корреляций по каждой паре
disp('Корреляции по парам:');
disp(corr_values);

% Визуализация корреляции по каждой паре
figure;
bar(corr_values);
xlabel('Pair');
ylabel('Correllation (Pearson)');
title('Correllation between L и R for each pair of signal');
set(gca, 'XTickLabel', selectedPairNames, 'XTick', 1:num_pairs); % Устанавливаем имена на ось X

% legend_labels = arrayfun(@(x) selectedPairNames(x), 1:num_pairs, 'UniformOutput', false);
% legend(legend_labels, 'Location', 'eastoutside'); % Move legend outside

grid on;
