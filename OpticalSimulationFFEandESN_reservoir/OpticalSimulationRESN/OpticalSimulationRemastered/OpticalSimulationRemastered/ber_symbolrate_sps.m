clc
close all

% Parameters
M = 4; % PAM encoding
number_of_symbols = 40000; % Number of symbols
symbol_rates = [20 30 40 50 100 200 300] * 1e9; % Data rate 
sample_per_symbols = [1 2 3];
ber_results = zeros(length(symbol_rates), length(sample_per_symbols)); % Vector to store BER results
adc_rate = zeros(length(symbol_rates), length(sample_per_symbols)); % Initialize adc_rate matrix
plot_laser_output = 0;  % Show the power of the field after the laser
plot_electric_signal = 0;
plot_oscilloscope = 0; % Show the signal that is received by the photodiode
plot_eye_diagram = 1; % Show the eye diagram
points_per_symbol = 10;  % Points per symbol for the simulation
fiber_length = 100e3;  % The length of the optical fiber (100 km)
points_per_space_step = 1000;  % Grid points for the optical fiber
D = 1e-5; % Dispersion Coefficient (s/m-m)
central_wavelength = 1550e-9; % Central wavelength in C-band (m)
gain = 15;  % EDFA gain (15 dB)
Pwr_dBm = 10; % Laser Power (10 dBm, 10 mW)
pd_bandwidth = 0.75 * symbol_rates(1); % Photodiode bandwidth (0.75 times the first symbol rate)
back_to_back = 0;  % If 0 it performs back-to-back transmission (no optical fiber). Otherwise, set 1.
taps = 30;

for i = 1:length(symbol_rates)
    symbol_rate = symbol_rates(i);
    for j = 1:length(sample_per_symbols)
        sample_per_symbol = sample_per_symbols(j);
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
            
            [number_of_symbols,n_ignore,samples_per_symbol,custom_rate, X_for_network,y_for_network,digital_X] = post_processing(taps,photocurrent, y, points_per_symbol, symbol_rate, adc_rate(i, j), number_of_symbols, n_ignore);

            [ber]=RidgeReg(M,X_for_network,y_for_network);
            ber_results(i, j) = ber;
        end
        
        % Display output
        disp(['Samples per symbol = ', num2str(sample_per_symbol), ' and symbol rate = ', num2str(symbol_rate)]);
        disp(['BER from Ridge Regression = ', num2str(ber_results(i, j))]);
    end
end
