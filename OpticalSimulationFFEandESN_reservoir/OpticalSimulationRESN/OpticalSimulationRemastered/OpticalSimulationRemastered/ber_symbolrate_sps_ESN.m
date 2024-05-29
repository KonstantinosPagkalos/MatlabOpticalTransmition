clc
close all

% Parameters
M = 4; % PAM encoding
number_of_symbols = 40000; % Number of symbols
symbol_rates = [100 90 80 70 60 50 40 30 20 10] * 1e9; % Data rate 
sample_per_symbols = [1 2 3];
ber_results = zeros(length(symbol_rates), length(sample_per_symbols)); % Vector to store BER results
adc_rate = zeros(length(symbol_rates), length(sample_per_symbols)); % Initialize adc_rate matrix
points_per_symbol = 10;  % Points per symbol for the simulation
fiber_length = 40e3;  % The length of the optical fiber (100 km)
points_per_space_step = 1000;  % Grid points for the optical fiber
D = 1e-5; % Dispersion Coefficient (s/m-m)
central_wavelength = 1550e-9; % Central wavelength in C-band (m)
gain = 15;  % EDFA gain (15 dB)
Pwr_dBm = 10; % Laser Power (10 dBm, 10 mW)
pd_bandwidth = 0.75 * symbol_rates(1); % Photodiode bandwidth (0.75 times the first symbol rate)
back_to_back = 0;  % If 0 it performs back-to-back transmission (no optical fiber). Otherwise, set 1.

for j = 1:length(sample_per_symbols)
    sample_per_symbol = sample_per_symbols(j);
    for i = 1:length(symbol_rates)
        symbol_rate = symbol_rates(i);
        adc_rate(i, j) = sample_per_symbol * symbol_rate; % Update adc_rate matrix

        % Create Analog Input
        [electric_signal, sample_freq,x, y, n_ignore] = create_pam(M, number_of_symbols, symbol_rate, points_per_symbol);

        % Run the laser source
        n_samples = length(electric_signal);
        I_bias = 50e-3;
        [field, time] = laser(I_bias, n_samples, sample_freq, Pwr_dBm, plot_laser_output);

        % Modulate the optical field
        bias_ratio = 0.3;
        field = modulator(field, electric_signal, bias_ratio, sample_freq, "AM", plot_electric_signal);

        % Receiver
        if back_to_back == 1
            photocurrent = photodiode(field, sample_freq, pd_bandwidth, central_wavelength, plot_oscilloscope);
            ber_results(i, j) = digital_receiver(photocurrent, y, points_per_symbol, n_ignore, M, plot_eye_diagram);
        else
            space_step = fiber_length / points_per_space_step; % Define space_step
            field = optical_fiber(field, fiber_length, space_step, sample_freq, D, central_wavelength);
            field = edfa(field, gain, central_wavelength, sample_freq);
            photocurrent = photodiode(field, sample_freq, pd_bandwidth, central_wavelength, plot_oscilloscope);

            ber_esn = ESN(points_per_symbol,M,y,n_ignore,adc_rate(i,j),symbol_rate,number_of_symbols,photocurrent);
            ber_results(i, j) = ber_esn;
        end

        % Display output
        disp(['Samples per symbol = ', num2str(sample_per_symbol), ' and symbol rate = ', num2str(symbol_rate/1e9)]);
        disp(['BER from ESN = ', num2str(ber_results(i, j))]);
    end
end


ber_results = ber_results';
ber_results_inversed = fliplr(ber_results);
symbol_rates_inverse =  fliplr(symbol_rates/1e9);
Y= sample_per_symbols; % Convert symbol rates to Gsa/s
X= symbol_rates_inverse; % Convert fiber lengths to km

% Plot heatmap
figure;
imagesc(X, Y, log10(ber_results_inversed ));
colorbar;

xlabel('Symbol Rate Gsa/s');
ylabel('samples per symbol');
title('BER from ESN Heatmap');


% Set the x-axis and y-axis ticks to exactly match tap_values
xticks(X);
yticks(Y);


% Set colorbar label
colorbarLabel = 'BER';
ylabel(colorbar, colorbarLabel);




figure;
heatmap(X, Y, log10(ber_results_inversed ));


xlabel('Symbol Rate Gsa/s');
ylabel('samples per symbol');
title('BER from ESN Heatmap');
