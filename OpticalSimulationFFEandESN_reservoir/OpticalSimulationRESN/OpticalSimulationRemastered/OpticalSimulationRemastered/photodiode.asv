function [photocurrent] = photodiode(field,sample_freq, bandwidth, central_wavelength, plot_oscilloscope)
   % This function implemements the photodiode
   % Inputs
   % field: The complex field at its input
   % sample_freq: The bandwidth of the simulation (Hz)
   % central_wavelength: The central wavelength of the carrier (m)
   % plot_oscilloscope: Plot the electical output of the photodiode
   % Outputs
   % photocurent: The photocurrent (A)


    RL = 50;
    RS = 0.75;
    h = 6.626070040e-34;
    c = 299792458;
    boltzmann_constant = 1.380649e-23;
    temperature = 300;
    dt = 1/sample_freq;

    % Shot and Thermal Noise
    shot_noise_density = 0.5 * h * (c / central_wavelength) / dt;
    
    field = field + sqrt(shot_noise_density/2)*(randn(1,length(field)) + 1j*randn(1,length(field)));
    
    photocurrent = RS*abs(field).^2;
    
    thermal_noise_density = 4 * boltzmann_constant * temperature / (RL * dt);
    
    photocurrent = photocurrent + sqrt(thermal_noise_density)*randn(1,length(field));
    
    % Low Pass Filter
    
    photocurrent = butterworth(photocurrent, sample_freq, bandwidth, 4);


    



    if plot_oscilloscope == 1
       t = 0:dt:dt*length(photocurrent)-dt;
       volt = RL*photocurrent;
       figure
       plot(t*1e9, volt*1e3);
       xlabel('Time (ns)');
       ylabel('Volt (mV)');
       grid on
    end

end

function [y] = butterworth(x, sample_freq, bandwidth, n)
    
    nyquist_freq = sample_freq/2;
    f = linspace(-nyquist_freq, nyquist_freq, length(x));
    
    h = 1./(1+1j*(f/bandwidth).^n);
    
    x_spectrum = fftshift(fft(x));
    y_spectrum = x_spectrum.*h;
    y = ifft(ifftshift(y_spectrum));
    
    y = abs(y);

end