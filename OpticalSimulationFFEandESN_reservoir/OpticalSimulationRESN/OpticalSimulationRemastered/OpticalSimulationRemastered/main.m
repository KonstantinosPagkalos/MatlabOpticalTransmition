clc
close all

% Parameters
M = 4; % PAM encoding
number_of_symbols = 40000; % Number of symbols
symbol_rate = 20e9; % Data rate (10 Gsa/s)
sample_per_symbol = 1;
adc_rate = sample_per_symbol*symbol_rate;
taps=20;
pd_bandwidth = 0.75*symbol_rate; % Photodiode bandwidth (10 GHz)
points_per_symbol = 10;  % Points per symbol for the simulation
fiber_length =50e3;  % The length of the optical fiber (50 km)
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
plot_eye_diagram = 1; % Show the eye diagram
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
    %ber = digital_receiver(photocurrent, y, points_per_symbol, n_ignore, M, plot_eye_diagram);
else
    space_step = fiber_length / points_per_space_step; % Define space_step
    field = optical_fiber(field, fiber_length, space_step, sample_freq, D, central_wavelength);
    field = edfa(field, gain, central_wavelength, sample_freq);
    photocurrent = photodiode(field, sample_freq, pd_bandwidth, central_wavelength, plot_oscilloscope);

    [ber_r] = digital_receiver(photocurrent, y, points_per_symbol, n_ignore, M);
    % Call post_processing function with updated parameters
     [number_of_symbols,n_ignore,samples_per_symbol,custom_rate, X_for_network,y_for_network,digital_X] = post_processing(taps,photocurrent, y, points_per_symbol, symbol_rate, adc_rate, number_of_symbols, n_ignore);
      %ridge regretion for the optical dataset
     [ber,star_test_predict,star_test] = RidgeReg(M,X_for_network,y_for_network);
     %ESN for the optical dataset
     [ber_esn,star_test_predict_ESN, star_test_ESN] = ESN(points_per_symbol,M,y,n_ignore,adc_rate,symbol_rate,number_of_symbols,photocurrent);









     %[ber_esn_matrix,nInternalUnits, spectralRadius] = ESNdiagram(points_per_symbol,M,y,n_ignore,adc_rate,symbol_rate,number_of_symbols,photocurrent);
     
   


    %[ber_esn_matrix,nInternalUnits] = ESNdiagram_nodes_taps_ber(points_per_symbol,M,y,n_ignore,adc_rate,symbol_rate,number_of_symbols,photocurrent);
     
end






