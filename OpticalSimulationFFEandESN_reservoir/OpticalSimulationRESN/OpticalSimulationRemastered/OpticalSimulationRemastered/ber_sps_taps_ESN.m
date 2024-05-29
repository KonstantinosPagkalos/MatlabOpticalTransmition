% clc
% close all
% 
% % Parameters
% M = 4; % PAM encoding
% number_of_symbols = 40000; % Number of symbols
% symbol_rate = 20e9; % Data rate (10 Gsa/s)
% sample_per_symbol = [1 2 3];
% adc_rate = sample_per_symbol*symbol_rate;
% pd_bandwidth = 0.75*symbol_rate; % Photodiode bandwidth (10 GHz)
% points_per_symbol = 10;  % Points per symbol for the simulation
% fiber_length =40e3;  % The length of the optical fiber (50 km)
% points_per_space_step = 1000;  % Grid points for the optical fiber
% D = 1e-5; % Dispersion Coefficient (s/m-m)
% central_wavelength = 1550e-9; % Central wavelength in C-band (m)
% gain = 15;  % EDFA gain (15 dB)
% Pwr_dBm = 10; % Laser Power (10 dBm, 10 mW)
% bermatrix = zeros(size(sample_per_symbol));
% 
% % Loop through sample per symbol
% for sps_index = 1:length(sample_per_symbol)
%     % Retrieve sample per symbol value
%     samples_per_symbol = sample_per_symbol(sps_index);
% 
%     % Display iteration information
%     disp(['Samples per symbol = ', num2str(samples_per_symbol)]);
% 
% 
%         % Create Analog Input
%         [electric_signal, sample_freq, ~, y, n_ignore] = create_pam(M, number_of_symbols, symbol_rate, points_per_symbol);
% 
%         % Run the laser source
%         n_samples = length(electric_signal);
%         I_bias = 50e-3;
%         [field, ~] = laser(I_bias, n_samples, sample_freq, Pwr_dBm, false); % Avoid plotting laser output
% 
%         % Modulate the optical field
%         bias_ratio = 0.3;
%         field = modulator(field, electric_signal, bias_ratio, sample_freq, "AM", false); % Avoid plotting electric signal
% 
%         % Receiver
%         space_step = fiber_length / points_per_space_step; % Define space_step
%         field = optical_fiber(field, fiber_length, space_step, sample_freq, D, central_wavelength);
%         field = edfa(field, gain, central_wavelength, sample_freq);
%         photocurrent = photodiode(field, sample_freq, pd_bandwidth, central_wavelength, false); % Avoid plotting oscilloscope
% 
%         bermatrix(sps_index) = ESN(points_per_symbol, M, y, n_ignore, adc_rate(sps_index), symbol_rate, number_of_symbols, photocurrent);
% 
%         % Display BER
%         disp(['BER from ESM = ', num2str(bermatrix(sps_index))]);
% 
% 
% 
% end
% 
% 
% disp(bermatrix);

ber_matrix1 = [0.00094967         0         0] ;
ber_matrix2 = [0     0     0] ;
ber_matrix3 = [0     0     0] ;
ber_matrix4 = [0     0     0] ;
ber_matrix5 = [0     0     0] ;
ber_matrix6 = [0     0     0] ; 



ber_matrix = [ber_matrix1; ber_matrix2; ber_matrix3; ber_matrix4; ber_matrix5; ber_matrix6]';

tapVector = [1 10 20 30 40 50]; 


samples_per_symbol = [1 2 3];





X = tapVector;

Y =  samples_per_symbol;  





figure;
heatmap(X, Y, log10(ber_matrix));


xlabel('Taps');
ylabel('Samples per Symbol');
title('BER from ESN');








