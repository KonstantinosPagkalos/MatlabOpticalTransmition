clc
close all

% Parameters
M = 4; % PAM encoding
number_of_symbols = 40000; % Number of symbols
symbol_rates = [10 20 30 40 50 60 70 80 90 100]*1e9;
sample_per_symbol = 1;
adc_rate = sample_per_symbol*symbol_rates;
tapVector = [1 10 20 30 40 50];
pd_bandwidth = 0.75*symbol_rates; % Photodiode bandwidth (10 GHz)
points_per_symbol = 10;  % Points per symbol for the simulation
fiber_length = 40e3;  % The length of the optical fiber (50 km)
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

% Initialize ber matrix
bermatrix = zeros(size(symbol_rates));

for i = 1:length(symbol_rates)
    symbol_rate = symbol_rates(i);

    % Create Analog Input
    [electric_signal, sample_freq, x, y, n_ignore] = create_pam(M, number_of_symbols, symbol_rate, points_per_symbol);

    % Run the laser source
    n_samples = length(electric_signal);
    I_bias = 50e-3;
    [field, time] = laser(I_bias, n_samples, sample_freq, Pwr_dBm, plot_laser_output);

    % Modulate the optical field
    bias_ratio = 0.3;
    field = modulator(field, electric_signal, bias_ratio, sample_freq, "AM", plot_electric_signal);

    % Receiver
    if back_to_back == 1
        photocurrent = photodiode(field, sample_freq, pd_bandwidth(i), central_wavelength, plot_oscilloscope);
        bermatrix(i) = digital_receiver(photocurrent, y, points_per_symbol, n_ignore, M, plot_eye_diagram);
    else
        space_step = fiber_length / points_per_space_step; % Define space_step
        field = optical_fiber(field, fiber_length, space_step, sample_freq, D, central_wavelength);
        field = edfa(field, gain, central_wavelength, sample_freq);
        photocurrent = photodiode(field, sample_freq, pd_bandwidth(i), central_wavelength, plot_oscilloscope);


        % ESN for the optical dataset
        fprintf('Symbol rate = %d Gsa/s\n',symbol_rate/1e9);
        bermatrix(i) = ESN(points_per_symbol, M, y, n_ignore, adc_rate(i), symbol_rate, number_of_symbols, photocurrent);
        fprintf('BER = %d\n', bermatrix(i));
    end
end

% Display ber matrix
disp('BER Matrix:');
disp(bermatrix);











%tapVector = [1 10 20 30 40 50];


 ber_matrix1 = [0    0.0007    0.1806    0.2081    0.2371    0.2833    0.2993    0.3105    0.3391    0.3470] ;
 ber_matrix2 = [0         0    0.0694    0.0583    0.1457    0.1918    0.2416    0.2702    0.3024    0.3157] ;
 ber_matrix3 = [0         0    0.0258    0.0380    0.0990    0.1598    0.1861    0.2097    0.2374    0.2747] ;
 ber_matrix4 = [0         0    0.0157    0.0130    0.0793    0.1202    0.1569    0.1854    0.2087    0.2476] ;
 ber_matrix5 = [0         0    0.0037    0.0061    0.0584    0.1060    0.1401    0.1812    0.1903    0.2331] ;
 ber_matrix6 = [0         0    0.0048    0.0049    0.0386    0.0822    0.1298    0.1596    0.1733    0.2135] ; 

ber_matrix = [ber_matrix1; ber_matrix2; ber_matrix3; ber_matrix4; ber_matrix5; ber_matrix6];











X = symbol_rates/1e9;  
Y = tapVector; 





imagesc(X, Y, log10(ber_matrix));
colormap('parula'); % You can replace 'parula' with other colormaps
colorbar;
title('BER from ESN');
xlabel('Symbol Rate (Gsa/s)');
ylabel('Taps');

% Set the x-axis and y-axis ticks to exactly match tap_values
xlim([min(X(:)), max(X(:))]);
yticks(Y);


% Set colorbar label
colorbarLabel = 'BER';
ylabel(colorbar, colorbarLabel);

figure;
heatmap(X, Y, log10(ber_matrix));


xlabel('Symbol Rate (Gsa/s)');
ylabel('Taps');
title('BER from ESN');
