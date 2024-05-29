function [ber_esn_matrix,nInternalUnits, spectralRadius] = ESNdiagram(points_per_symbol,M,y,n_ignore,adc_rate,symbol_rate,number_of_symbols,photocurrent)
   
    % Initialize nInternalUnits and spectralRadius vectors
    nInternalUnits = [10, 20, 30, 40, 50];
    spectralRadius = [0.1, 0.3, 0.5, 0.7, 0.9, 1.1, 1.3];

    % Initialize ber_esn_matrix
    ber_esn_matrix = zeros(length(nInternalUnits), length(spectralRadius));
    
    [inputSequence, outputSequence,samples_per_symbol] = generate_optical_sequence(points_per_symbol,y,photocurrent,number_of_symbols,n_ignore,adc_rate,symbol_rate);

    % Split the data into train and test
    n_total_symbols = length(outputSequence);
    n_train = ceil(0.5 * n_total_symbols);
    n_test = n_total_symbols - n_train;

    trainInputSequence = inputSequence(1:n_train, :);
    testInputSequence = inputSequence(1 + n_train:n_train + n_test, :);

    trainOutputSequence = outputSequence(1:n_train, :);
    testOutputSequence = outputSequence(1 + n_train:n_train + n_test, :);

    testOutputSequence = testOutputSequence(n_ignore:end - n_ignore, :);

    % Generate an ESN 
    nInputUnits = samples_per_symbol + 1;
    nOutputUnits = 1;

    % Create input scaling vector with (samples_per_symbol + 1) 0.1's
    inputScalingVector = 0.1 * ones(nInputUnits, 1);

    % Create input shift vector with zeros in the same amount as samples_per_symbol + 1
    inputShiftVector = zeros(nInputUnits, 1);

    % Loop over each combination of nInternalUnits and spectralRadius
    for i = 1:length(nInternalUnits)
        for j = 1:length(spectralRadius)
            esn = generate_esn(nInputUnits, nInternalUnits(i), nOutputUnits, ...
                'spectralRadius', spectralRadius(j), 'inputScaling', inputScalingVector, 'inputShift', inputShiftVector, ...
                'teacherScaling', 0.3, 'teacherShift', -0.2, 'feedbackScaling', 0, ...
                'type', 'plain_esn');
            esn.internalWeights = esn.spectralRadius * esn.internalWeights_UnitSR;

            % Train the ESN
            nForgetPoints = 100; % discard the first 100 points
            [trainedEsn, ~] = train_esn(trainInputSequence, trainOutputSequence, esn, nForgetPoints);

            % Compute predicted outputs
            predictedTestOutput = test_esn(testInputSequence, trainedEsn, nForgetPoints);

            % Compute BER
            star_test_predict_ESN = pamdemod(predictedTestOutput, M);
            star_test_ESN = pamdemod(testOutputSequence(nForgetPoints+1:end,:), M);
            [~, ber_esn] = biterr(star_test_predict_ESN, star_test_ESN);

            % Store BER in the matrix
            ber_esn_matrix(i, j) = ber_esn;

            % Display the result
            disp(['nInternalUnits = ', num2str(nInternalUnits(i)), ' and spectralRadius = ', num2str(spectralRadius(j))]);
            disp(['ber_esn = ', num2str(ber_esn)]);
        end
    end

    X = spectralRadius;  
    Y = nInternalUnits; 





imagesc(X, Y, log10(ber_esn_matrix));
colormap('parula'); % You can replace 'parula' with other colormaps
colorbar;
title('BER from ESN');
xlabel('spectralRadius');
ylabel('nInternalUnits');

% Set the x-axis and y-axis ticks to exactly match tap_values
xticks(X);
yticks(Y);


% Set colorbar label
colorbarLabel = 'BER';
ylabel(colorbar, colorbarLabel);

figure;
heatmap(X, Y, log10(ber_esn_matrix));


title('BER from ESN');
xlabel('spectralRadius');
ylabel('nInternalUnits');





end
