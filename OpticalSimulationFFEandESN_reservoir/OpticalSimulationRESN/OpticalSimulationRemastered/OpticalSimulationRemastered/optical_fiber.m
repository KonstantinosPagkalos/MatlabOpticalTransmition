function [output_field] = optical_fiber(field, fiber_length, space_step, sample_freq, D, central_wavelength)
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This function implements the transmission
    % Inputs
    % field: The complex field
    % fiber length: The length of the fiber (m)
    % space_step: The step of the simulation for the transmission (m)
    % sample_freq: The bandwidth of the simulation (Hz)
    % D: The dispersion coefficient (s/m-m)
    % central_wavelength : The central wavelength of the carrier (m)
    % Outputs
    % output_field: The complex field at the output
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    c_speed = 299792458; % Speed of Light (m/s)

    n_time_samples = length(field);
    n_space_samples = ceil(fiber_length/space_step);

    % Spectral Properties
    nyquist_freq = sample_freq/2;
    f = linspace(-nyquist_freq, nyquist_freq, n_time_samples);
    angular_frequency = 2*pi*f;

    b2 = -(central_wavelength^2)*D/(2*pi*c_speed);  %Second order dispersion in s^2/m
    b3 = 0; % Third order dispersion in s^3/m
    g = 1.3e-3; % nonlinear parameter in 1/(W*m)
    fiber_losses_dB = 0.2; % fiber losses in dB for C-band
    fiber_losses = -fiber_losses_dB/(10*fiber_length*log10(exp(1)));

    sources = exp(-fiber_losses*space_step/2 + 1j*((angular_frequency.^2)*b2*space_step/2 + ...
        (angular_frequency).^3*b3*space_step/6));
  
    % Transmission
    
    % Input Coupling losses
    output_field = field*sqrt(0.4);
    
    for i =1:n_space_samples
       power = abs(output_field).^2;
       output_field = output_field.*exp(1j*g*power*space_step);
       output_field_spectrum = fftshift(fft(output_field));
       output_field_spectrum = sources.*output_field_spectrum;
       output_field = ifft(ifftshift(output_field_spectrum));
    end
    
     % Output Coupling losses
      output_field = output_field*sqrt(0.4);
      
      axis=1;

end

