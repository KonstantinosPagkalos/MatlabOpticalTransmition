clc
close all

% Parameters
M = 4; % PAM encoding
number_of_symbols = 40000; 
symbol_rates = [20 50 200] * 1e9; % Data rates (10 Gsa/s)
fiber_length = 20e3; % Fiber lengths in meters
sample_per_symbols = [1 2 3];
adc_rates = sample_per_symbols .* symbol_rates;
pd_bandwidth = 0.75 * symbol_rates; % Photodiode bandwidth
points_per_symbol = 10; % Points per symbol for the simulation
points_per_space_step = 1000; % Grid points for the optical fiber
taps = 40;
D = 1e-5; % Dispersion Coefficient (s/m-m)
central_wavelength = 1550e-9; % Central wavelength in C-band (m)
gain = 15; % EDFA gain (15 dB)
Pwr_dBm = 10; % Laser Power (10 dBm, 10 mW)

% Initialize BER matrix
ber_matrix = zeros(length(symbol_rates), length(sample_per_symbols));

% Loop through sample per symbol
for x_index = 1:length(sample_per_symbols)
    
    sample_per_symbol = sample_per_symbols(x_index);
    
    % Loop through symbol rates
    for y_index = 1:length(symbol_rates)
        
        symbol_rate = symbol_rates(y_index);
        adc_rate=adc_rates(y_index);
        % Display iteration information
        disp(['Samples per symbol = ', num2str(sample_per_symbol), ', Symbol rate = ', num2str(symbol_rate / 1e9), ' Gsa/s']);
        
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
        [ number_of_symbols, n_ignore, samples_per_symbol, custom_rate, X_for_network, y_for_network, digital_X] = post_processing(taps, photocurrent, y, points_per_symbol, symbol_rate, adc_rate, number_of_symbols, n_ignore);
        
        % Ridge regression for the optical dataset
        [ber] = RidgeReg(M, X_for_network, y_for_network);
        
        % Store BER value
        ber_matrix(x_index, y_index) = ber;
        

    end
end

X = (symbol_rates / 1e9); % Convert symbol rates to Gsa/s
Y = sample_per_symbols; % Convert fiber lengths to km

% Plot heatmap
figure;
imagesc(X, Y, log10(ber_matrix));
colorbar;

xlabel('Symbol rates (Gsa/s)');
ylabel('Samples per symbol');
title('BER Heatmap');

% Set the x-axis and y-axis ticks to exactly match tap_values
xticks(X);
yticks(Y);

% Set colorbar label
colorbarLabel = 'log10(BER)';
ylabel(colorbar, colorbarLabel);
