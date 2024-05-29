clc
close all

% Parameters
M = 4; % PAM encoding
number_of_symbols = 40000;
symbol_rate = 20e9; % Data rate (30 Gsa/s)
fiber_length = 40e3; % Fiber length (40 km)
sample_per_symbol = [1 2 3];
adc_rate = sample_per_symbol * symbol_rate;
pd_bandwidth = 0.75 * symbol_rate; % Photodiode bandwidth
points_per_symbol = 10; % Points per symbol for the simulation
points_per_space_step = 1000; % Grid points for the optical fiber
taps = [1 10 20 30 40 50];
D = 1e-5; % Dispersion Coefficient (s/m-m)
central_wavelength = 1550e-9; % Central wavelength in C-band (m)
gain = 15; % EDFA gain (15 dB)
Pwr_dBm = 10; % Laser Power (10 dBm, 10 mW)

% Initialize BER matrix
ber_matrix = zeros(length(sample_per_symbol), length(taps));

% Loop through sample per symbol
for sps_index = 1:length(sample_per_symbol)
    % Retrieve sample per symbol value
    samples_per_symbol = sample_per_symbol(sps_index);
    
    % Display iteration information
    disp(['Samples per symbol = ', num2str(samples_per_symbol)]);
    
    % Loop through taps
    for taps_index = 1:length(taps)
        % Retrieve taps value
        tap = taps(taps_index);
        
        % Display iteration information
        disp(['  Taps = ', num2str(tap)]);
        
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
        photocurrent = photodiode(field, sample_freq, pd_bandwidth, central_wavelength, false); % Avoid plotting oscilloscope

        % Call post_processing function with updated parameters
        [ number_of_symbols, n_ignore, ~, ~, X_for_network, y_for_network, ~] = post_processing(tap, photocurrent, y, points_per_symbol, symbol_rate, adc_rate(sps_index), number_of_symbols, n_ignore);
        
        % Ridge regression for the optical dataset
        [ber] = RidgeReg(M, X_for_network, y_for_network);
        
        % Display BER
        disp(['    BER from ridge regression = ', num2str(ber)]);
        
        % Store BER value
        ber_matrix(sps_index, taps_index) = ber;
    end
end



Y= sample_per_symbol; % Convert symbol rates to Gsa/s
X= taps; % Convert fiber lengths to km

% Plot heatmap
figure;
imagesc(X, Y, log10(ber_matrix));
colorbar;

xlabel('Taps');
ylabel('samples per symbol');
title('BER Heatmap');




% Set the x-axis and y-axis ticks to exactly match tap_values
xticks(X);
yticks(Y);


% Set colorbar label
colorbarLabel = 'BER';
ylabel(colorbar, colorbarLabel);



figure;
heatmap(X, Y, log10(ber_matrix));


xlabel('Taps');
ylabel('Samples per symbol');
title('BER Heatmap');



