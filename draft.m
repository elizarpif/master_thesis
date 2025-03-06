data = randn(100,1); % Пример нормальных данных

% Построение гистограммы
figure;
subplot(1,2,1);
histogram(data, 20);
title('Гистограмма');

% QQ-Plot (сравнение с нормальным распределением)
subplot(1,2,2);
qqplot(data);
title('QQ-Plot');