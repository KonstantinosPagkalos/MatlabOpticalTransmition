function[number_of_symbols,n_ignore,samples_per_symbol,custom_rate, X_for_network,y_for_network,digital_X] = post_processing( taps,photocurrent, y, points_per_symbol, symbol_rate, adc_rate, number_of_symbols, n_ignore)
    
    samples_per_symbol = floor(adc_rate / symbol_rate);

    % Downsample the photocurrent
    digital_X = resample(photocurrent,adc_rate,points_per_symbol*symbol_rate);
    custom_rate = samples_per_symbol*symbol_rate;
    digital_X = resample(digital_X,custom_rate,adc_rate);
    digital_X = normalize(digital_X);

     X_total = zeros(samples_per_symbol,number_of_symbols+n_ignore);
    for i = 1: number_of_symbols + n_ignore
      X_total(:,i) = digital_X(1+(i-1)*samples_per_symbol:i*samples_per_symbol); 
    end
    
    

    %X_Total = reshape(digital_X, [samples_per_symbol, number_of_symbols + n_ignore]);
     
    % Generate the X and Y without the laser symbols
    X = X_total(:, 1 + n_ignore:end);
    Y = y(1 + n_ignore:end);

    
    % Symbols due to dispersion
    
    tap_range = 1:taps;

    m = floor((1 + taps) / 2);
    tap_range = tap_range - m;

    X_tapped = zeros(samples_per_symbol * taps, number_of_symbols);

    for i = m:number_of_symbols - m
        surrounding_elements = X(:, i + tap_range);
        vector = reshape(surrounding_elements, 1, taps * samples_per_symbol);
        X_tapped(:, i) = vector;
    end
    % Parameters for the neural network
    X_for_network = X_tapped(:, n_ignore:end - n_ignore);

    y_for_network = Y(n_ignore:end - n_ignore);

    
   

    


   
end
