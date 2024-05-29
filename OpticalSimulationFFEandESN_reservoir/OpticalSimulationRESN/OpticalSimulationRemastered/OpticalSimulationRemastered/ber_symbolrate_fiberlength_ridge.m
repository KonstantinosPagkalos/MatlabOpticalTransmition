clc
close all

% Parameters
M = 4; % PAM encoding
number_of_symbols = 40000; 
symbol_rates = [20 30 40 50 100] * 1e9; % Data rates (10 Gsa/s)
fiber_lengths = [20 30 40 50 60 65 70 80] * 1e3; % Fiber lengths in meters
sample_per_symbol = 1;
adc_rate = sample_per_symbol * symbol_rates;
pd_bandwidth = 0.75 * symbol_rates; % Photodiode bandwidth
points_per_symbol = 10; % Points per symbol for the simulation
points_per_space_step = 1000; % Grid points for the optical fiber
taps=40;
D = 1e-5; % Dispersion Coefficient (s/m-m)
central_wavelength = 1550e-9; % Central wavelength in C-band (m)
gain = 15; % EDFA gain (15 dB)
Pwr_dBm = 10; % Laser Power (10 dBm, 10 mW)

% Initialize BER matrix
ber_matrix = zeros(length(symbol_rates), length(fiber_lengths));

% Loop through symbol rates
for x_index = 1:length(symbol_rates)
    % Retrieve symbol rate value
    symbol_rate = symbol_rates(x_index);
    
    % Loop through fiber lengths
    for y_index = 1:length(fiber_lengths)
        % Retrieve fiber length value
        fiber_length = fiber_lengths(y_index);
        
        % Display iteration information
        disp(['Symbol Rate = ', num2str(symbol_rate / 1e9), ' Gsa/s, Fiber Length = ', num2str(fiber_length / 1e3), ' km']);
        
        % Create Analog Input
        [electric_signal, sample_freq, ~, y, n_ignore] = create_pam(M, number_of_symbols, symbol_rate, points_per_symbol);

        % Run the laser source
        n_samples = length(electric_signal);
        I_bias = 50e-3;
        [field, ~] = laser(I_bias, n_samples, sample_freq, Pwr_dBm, false); % Avoid plotting laser output

        % Modulate the optical field
        bias_ratio = 0.3;
        field = modulator(field, electric_signal, bias_ratio, sample_freq, "AM", false); % Avoid plotting electric signal

        % Receiver
        space_step = fiber_length / points_per_space_step; % Define space_step
        field = optical_fiber(field, fiber_length, space_step, sample_freq, D, central_wavelength);
        field = edfa(field, gain, central_wavelength, sample_freq);
        photocurrent = photodiode(field, sample_freq, pd_bandwidth(x_index), central_wavelength, false); % Avoid plotting oscilloscope

        % Call post_processing function with updated parameters
        [ number_of_symbols, n_ignore, samples_per_symbol, custom_rate, X_for_network, y_for_network, digital_X] = post_processing(taps, photocurrent, y, points_per_symbol, symbol_rate, adc_rate(x_index), number_of_symbols, n_ignore);
        
        % Ridge regression for the optical dataset
        [ber] = RidgeReg(M, X_for_network, y_for_network);
        
        % Store BER value
        ber_matrix(x_index, y_index) = ber;
    end
end


X= (fiber_lengths / 1e3); % Convert fiber lengths to km
Y = (symbol_rates / 1e9); % Convert symbol rates to Gsa/s

% Plot heatmap
figure;
imagesc(X, Y, log10(ber_matrix));
colorbar;

xlabel('Fiber Length (km)');
ylabel('Symbol Rate (Gsa/s)');

title('BER from ESN');


% Adjust x-axis limits
xticks(X);
yticks(Y);


% Set colorbar label
colorbarLabel = 'BER';
ylabel(colorbar, colorbarLabel);

figure;
heatmap(X, Y, log10(ber_matrix));


xlabel('fiber length (km)');
ylabel('Symbol Rate (Gsa/s)');
title('BER Heatmap');
