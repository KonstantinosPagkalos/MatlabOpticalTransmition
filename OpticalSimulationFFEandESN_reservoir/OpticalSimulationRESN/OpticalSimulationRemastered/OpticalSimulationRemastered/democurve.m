% Generate taps vector
taps = [1 10 20 30 40 50];

ber = [0.00065498 0 0 0 0 0]; 

% Plotting
figure;
plot(taps, log10(ber), 'o-');
xlabel('Taps');
ylabel('BER');
title('BER vs Taps');
grid on;
set(gca, 'YDir', 'reverse'); % Reverse the y-axis direction
