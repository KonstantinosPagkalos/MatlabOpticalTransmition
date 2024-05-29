function [inputSequence, outputSequence,samples_per_symbol] = generate_optical_sequence(points_per_symbol,y,photocurrent,number_of_symbols,n_ignore,adc_rate,symbol_rate )



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
    
    
    
    X = X_total(:, 1 + n_ignore:end);
    Y = y(1 + n_ignore:end);

    
    inputSequence = [ones(1, size(X, 2)); X]';
    outputSequence  = Y';

    
    
    
    
end
