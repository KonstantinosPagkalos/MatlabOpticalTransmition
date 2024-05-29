clc;
close all;

% Parameters
M = 4; % PAM encoding
number_of_symbols = 40000; % Number of symbols
symbol_rate = [20,30,40,50,100]*1e9; % Data rate (10 Gsa/s)
sample_per_symbol = 1;
taps = 20;
pd_bandwidth = 0.75 * symbol_rate; % Photodiode bandwidth (10 GHz)
points_per_symbol = 10;  % Points per symbol for the simulation
fiber_length = [20, 30, 40, 50, 60, 65, 70, 80]*1e3;  % The length of the optical fiber (50 km)
points_per_space_step = 1000;  % Grid points for the optical fiber
D = 1e-5; % Dispersion Coefficient (s/m-m)
central_wavelength = 1550e-9; % Central wavelength in C-band (m)
gain = 15;  % EDFA gain (15 dB)
Pwr_dBm = 10; % Laser Power (10 dBm, 10 mW)

% Perform
back_to_back = 0;  % If 0 it performs back-to-back transmission (no optical fiber). Otherwise, set 1.

% Show plots
plot_laser_output = 0;  % Show the power of the field after the laser
plot_electric_signal = 0;
plot_oscilloscope = 0; % Show the signal that is received by the photodiode
plot_eye_diagram = 0; % Show the eye diagram

% Create a matrix to store BER results
ber_results = zeros(length(symbol_rate), length(fiber_length));

% Loop over each symbol rate
for sr_idx = 1:length(symbol_rate)
    current_symbol_rate = symbol_rate(sr_idx);
    current_adc_rate = sample_per_symbol * current_symbol_rate;
    current_pd_bandwidth = 0.75 * current_symbol_rate;
    
    % Create Analog Input
    [electric_signal, sample_freq, x, y, n_ignore] = create_pam(M, number_of_symbols, current_symbol_rate, points_per_symbol);
    
    % Run the laser source
    n_samples = length(electric_signal);
    I_bias = 50e-3;
    [field, time] = laser(I_bias, n_samples, sample_freq, Pwr_dBm, plot_laser_output);
    
    % Modulate the optical field
    bias_ratio = 0.3;
    field = modulator(field, electric_signal, bias_ratio, sample_freq, "AM", plot_electric_signal);
    
    % Loop over each fiber length
    for fl_idx = 1:length(fiber_length)
        current_fiber_length = fiber_length(fl_idx);
        
        % Receiver
        if back_to_back == 1
            photocurrent = photodiode(field, sample_freq, current_pd_bandwidth, central_wavelength, plot_oscilloscope);
            ber = digital_receiver(photocurrent, y, points_per_symbol, n_ignore, M, plot_eye_diagram);
        else
            space_step = current_fiber_length / points_per_space_step; % Define space_step
            field_transmitted = optical_fiber(field, current_fiber_length, space_step, sample_freq, D, central_wavelength);
            field_amplified = edfa(field_transmitted, gain, central_wavelength, sample_freq);
            photocurrent = photodiode(field_amplified, sample_freq, current_pd_bandwidth, central_wavelength, plot_oscilloscope);

            [ber] = digital_receiver(photocurrent, y, points_per_symbol, n_ignore, M);
        end
        
        % Store BER result
        ber_results(sr_idx, fl_idx) = ber;
        
        % Display BER result
        fprintf('For symbol_rate = %d Gbps and fiber_length = %d km, BER = %f\n', ...
                current_symbol_rate/1e9, current_fiber_length/1e3, ber);
    end
end

% Display the BER results matrix
disp('BER results:');
disp(ber_results);

ber_matrix= ber_results;

X= (fiber_length / 1e3); % Convert fiber lengths to km
Y = (symbol_rate / 1e9); % Convert symbol rates to Gsa/s

% Plot heatmap
figure;
imagesc(X, Y, log10(ber_matrix));
colorbar;

xlabel('Fiber Length (km)');
ylabel('Symbol Rate (Gsa/s)');

title('BER from Digital Receiver');


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
title('BER from Digital Receiver');



