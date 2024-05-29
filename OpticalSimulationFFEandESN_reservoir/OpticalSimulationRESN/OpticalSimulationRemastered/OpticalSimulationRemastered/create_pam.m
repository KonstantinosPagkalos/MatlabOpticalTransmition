function [electric_signal, sample_freq,x, y, n_ignore] = create_pam(M,number_of_symbols, symbol_rate, points_per_symbol)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This function creates the analog PAM - M signal
    % Outputs
    % electric signal: The analog electrical signal
    % sample_freq: The bandwidth of the simulation (Hz)
    % y: The symbols 0, 1, 2, ..., M-1
    % n_ignore: The symbols to be ignored, due to laser's set on time
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    dt_symbols = 1/symbol_rate;
    dt = dt_symbols/points_per_symbol;
    sample_freq = 1/dt;%fs
    n_ignore = 1000;
    n_total_symbols = n_ignore + number_of_symbols;
    y = randi(M,1, n_total_symbols)-1;
    y = pammod(y,M);
    % Generate an analog input, to modulate the optical field
    x = real(y);
    x = (x - min(x))/(max(x)-min(x));
    fs_analog = points_per_symbol*symbol_rate;
    electric_signal = resample(x, fs_analog, symbol_rate);
end
