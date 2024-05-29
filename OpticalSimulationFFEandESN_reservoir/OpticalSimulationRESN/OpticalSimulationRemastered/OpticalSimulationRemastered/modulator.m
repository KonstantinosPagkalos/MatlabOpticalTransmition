function [output_field] = modulator(field, electric_signal, bias_ratio,sample_freq, type, plot_electric_signal)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This function performs the modulation
    % Inputs
    % field : The complex field at the output of the laser
    % electric_signal: The signal to be modulated
    % bias_ratio: The ratio between the DC bias and the AC signal
    % sample_freq: The bandwidth of the simulation (Hz)
    % type: The modulation type (AM for amplitude modulation, PM for phase
    % modulation
    % plot_electric_signal: Choose either or not to plot the signal
    % Outputs
    % output_field: The modulated complex field
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    amplitude = 0;
    phase = 0;

    if strcmp(type,"AM")==1
       amplitude = sqrt(bias_ratio + (1-bias_ratio)*electric_signal);
    else
       phase = 2*np.pi*electric_signal; 
    end

    output_field = field.*amplitude.*exp(1j*phase);
    
    if plot_electric_signal == 1
       dt = 1/sample_freq;
       t = 0:dt:dt*length(amplitude)-dt;
       figure
       plot(t*1e9, amplitude.^2);
       xlabel('Time (ns)');
       title('Modulation');
       grid on
    end
end

