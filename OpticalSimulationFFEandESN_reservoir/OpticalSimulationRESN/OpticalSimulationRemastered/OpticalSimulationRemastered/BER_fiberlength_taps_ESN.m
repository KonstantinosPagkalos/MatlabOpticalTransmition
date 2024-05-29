% clc
% close all
% 
% % Parameters
% M = 4; % PAM encoding
% number_of_symbols = 40000; % Number of symbols
% symbol_rate = 20e9; % Data rate (10 Gsa/s)
% sample_per_symbol = 1;
% adc_rate = sample_per_symbol * symbol_rate;
% %tapVector = [1 10 20 30 40 50];
% fiber_lengths = [20 30 40 50 60 65 70 75] * 1e3;
% pd_bandwidth = 0.75 * symbol_rate; % Photodiode bandwidth (10 GHz)
% points_per_symbol = 10;  % Points per symbol for the simulation
% points_per_space_step = 1000;  % Grid points for the optical fiber
% D = 1e-5; % Dispersion Coefficient (s/m-m)
% central_wavelength = 1550e-9; % Central wavelength in C-band (m)
% gain = 15;  % EDFA gain (15 dB)
% Pwr_dBm = 10; % Laser Power (10 dBm, 10 mW)
% 
% % Show plots
% plot_laser_output = 0;  % Show the power of the field after the laser
% plot_electric_signal = 0;
% plot_oscilloscope = 0; % Show the signal that is received by the photodiode
% plot_eye_diagram = 1; % Show the eye diagram
% 
% % Perform
% back_to_back = 0;  % If 0 it performs back-to-back transmission (no optical fiber). Otherwise, set 1.
% 
% ber_matrix = zeros(length(fiber_lengths), 1); % Initialize BER matrix
% 
% for i = 1:length(fiber_lengths)
%     fiber_length = fiber_lengths(i);
% 
%     % Create Analog Input
%     [electric_signal, sample_freq, x, y, n_ignore] = create_pam(M, number_of_symbols, symbol_rate, points_per_symbol);
% 
%     % Run the laser source
%     n_samples = length(electric_signal);
%     I_bias = 50e-3;
%     [field, time] = laser(I_bias, n_samples, sample_freq, Pwr_dBm, plot_laser_output);
% 
%     % Modulate the optical field
%     bias_ratio = 0.3;
%     field = modulator(field, electric_signal, bias_ratio, sample_freq, "AM", plot_electric_signal);
% 
%     % Receiver
%     if back_to_back == 1
%         photocurrent = photodiode(field, sample_freq, pd_bandwidth, central_wavelength, plot_oscilloscope);
%         ber = digital_receiver(photocurrent, y, points_per_symbol, n_ignore, M, plot_eye_diagram);
%     else
%         space_step = fiber_length / points_per_space_step; % Define space_step
%         field = optical_fiber(field, fiber_length, space_step, sample_freq, D, central_wavelength);
%         field = edfa(field, gain, central_wavelength, sample_freq);
%         photocurrent = photodiode(field, sample_freq, pd_bandwidth, central_wavelength, plot_oscilloscope);
% 
%         % Call digital receiver function and calculate BER
%          fprintf('Fiber Length = %d km\n', fiber_length / 1000);
%          ber_esn = ESN(points_per_symbol,M,y,n_ignore,adc_rate,symbol_rate,number_of_symbols,photocurrent);
%     end
% 
%     % Store BER value in the matrix
%     ber_matrix(i) = ber_esn;
% 
%     % Display fiber length and BER
% 
% 
% end











tapVector = [1 10 20 30 40 50 60 70 80 90 100 110];
fiber_lengths=[ 10 20 30 40 50 60 65 70 75 80 90 100]*1e3;

%taps =1 : ber_matrix = [ 0         0    0.0007    0.0099    0.0383    0.0593    0.0820    0.1090] ;
%taps =10: ber_matrix = [ 0         0         0         0         0         0    0.0030    0.0165] ;
%taps =20: ber_matrix = [ 0         0         0         0         0         0         0    0.0054] ;
%taps= 30: ber_matrix = [ 0         0         0         0         0         0         0    0.0030] ;
%taps =40: ber_matrix = [ 0         0         0         0         0         0         0    0.0021] ;
%taps =50: ber_matrix = [0         0         0         0         0         0         0    0.0011]; 




ber_matrix1 = [ 0         0    0.0007    0.0099    0.0383    0.0593    0.0820    0.1090] ;
ber_matrix2 = [ 0         0         0         0         0         0    0.0030    0.0165] ;
ber_matrix3= [ 0         0         0         0         0         0         0    0.0054] ;
ber_matrix4= [ 0         0         0         0         0         0         0    0.0030] ;
ber_matrix5 = [ 0         0         0         0         0         0         0    0.0021] ;
ber_matrix6 = [0         0         0         0         0         0         0    0.0011]; 


ber_matrix = [ber_matrix1; ber_matrix2; ber_matrix3; ber_matrix4; ber_matrix5; ber_matrix6];









X = fiber_lengths / 1e3;  
Y = tapVector; 





imagesc(X, Y, log10(ber_matrix));
shading interp;
colormap('parula'); % You can replace 'parula' with other colormaps
colorbar;
title('BER from ESN');
xlabel('Fiber Length (km)');
ylabel('Taps');

% Set the x-axis and y-axis ticks to exactly match tap_values
xlim([min(X(:)), max(X(:))]);
yticks(Y);


% Set colorbar label
colorbarLabel = 'BER';
ylabel(colorbar, colorbarLabel);

figure;
heatmap(X, Y, log10(ber_matrix));


xlabel('fiber length (km)');
ylabel('Taps');
title('BER from ESN');



figure;
p = pcolor(X,Y,log10(ber_matrix)');
set(p, 'EdgeColor', 'none'); % Remove edges for smoother appearance
shading interp; % Interpolate colors for smooth transition
colorbar; % Add colorbar to show the scale
colormap('jet'); % Choose colormap for smooth color transitions

title('BER from ESN');
xlabel('Fiber Length (km)');
ylabel('Taps');

% Set the x-axis and y-axis ticks to exactly match tap_values
xlim([min(X(:)), max(X(:))]);
yticks(Y);


% Set colorbar label
colorbarLabel = 'BER';
ylabel(colorbar, colorbarLabel);




