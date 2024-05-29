function [output_field] = edfa(field, gain, central_wavelength, sample_freq)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This function implements the erbium fiber amplifier
    % Inputs
    % field: The complex field at the input
    % gain : The gain of the EDFA (dB)
    % central_wavelength: The wavelengt of the carrier (m)
    % sample_freq: The bandwidth of the simulation (Hz)
    % Outputs
    % output_field: The complex field at the output
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    h = 6.626070040e-34;
    nsp = 1.5;
    dt = 1/sample_freq;

    gain_linear = 10^(gain/10);
    output_field = field*sqrt(gain_linear);

    noise_spectral_density = h*central_wavelength*nsp*(gain_linear-1)/dt;

    x1 = randn(1, length(field));
    x2 = randn(1, length(field));

    output_field = output_field + sqrt(noise_spectral_density/2)*(x1 + 1j*x2);


end

