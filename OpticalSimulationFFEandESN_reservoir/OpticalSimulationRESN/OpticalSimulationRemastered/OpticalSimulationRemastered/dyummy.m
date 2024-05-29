% Define the ranges for x and y axes
X= (symbol_rates / 1e9); % Convert symbol rates to Gsa/s
Y = (fiber_lengths / 1e3); % Convert fiber lengths to km



% Plot the heatmap
figure;
imagesc(X, Y, log10(ber_matrix));
colorbar;
xlabel('Symbol Rate (Gsa/s)');
ylabel('Fiber Length (km)');
title('BER');

% Adjust x-axis limits
xlim([min(x(:)), max(X(:))]);
ylim([min(Y(:)), max(Y(:))]);