function [ber_esn_matrix,nInternalUnits] = ESNdiagram_nodes_taps_ber(points_per_symbol,M,y,n_ignore,adc_rate,symbol_rate,number_of_symbols,photocurrent)
   
    [inputSequence, outputSequence, samples_per_symbol] = generate_optical_sequence(points_per_symbol, y, photocurrent, number_of_symbols, n_ignore, adc_rate, symbol_rate);

% Split the data into train and test
n_total_symbols = length(outputSequence);
n_train = ceil(0.5 * n_total_symbols);
n_test = n_total_symbols - n_train;

trainInputSequence = inputSequence(1:n_train, :);
testInputSequence = inputSequence(1 + n_train:n_train + n_test, :);

trainOutputSequence = outputSequence(1:n_train, :);
testOutputSequence = outputSequence(1 + n_train:n_train + n_test, :);

testOutputSequence = testOutputSequence(n_ignore:end - n_ignore, :);

%%%% generate an esn 
nInputUnits = samples_per_symbol + 1;
nInternalUnits = (50:25:300);
nOutputUnits = 1;

% Create input scaling vector with (samples_per_symbol + 1) 0.1's
inputScalingVector = 0.1 * ones(nInputUnits, 1);

% Create input shift vector with zeros in the same amount as samples_per_symbol + 1
inputShiftVector = zeros(nInputUnits, 1);

% Initialize an array to store BER for each value of nInternalUnits
ber_esn_matrix = zeros(size(nInternalUnits));

for i = 1:length(nInternalUnits)
    % Create ESN with current value of nInternalUnits
    esn = generate_esn(nInputUnits, nInternalUnits(i), nOutputUnits, ...
        'spectralRadius', 0.5, 'inputScaling', inputScalingVector, 'inputShift', inputShiftVector, ...
        'teacherScaling', 0.3, 'teacherShift', -0.2, 'feedbackScaling', 0, ...
        'type', 'plain_esn');
    
    % Scale internal weights
    esn.internalWeights = esn.spectralRadius * esn.internalWeights_UnitSR;

    % Train the ESN
    nForgetPoints = 100; % discard the first 100 points
    [trainedEsn, stateMatrix] = train_esn(trainInputSequence, trainOutputSequence, esn, nForgetPoints);

    % Predict output for training and testing data
    predictedTrainOutput = test_esn(trainInputSequence, trainedEsn, nForgetPoints);
    predictedTestOutput = test_esn(testInputSequence, trainedEsn, nForgetPoints);

    % Demodulate predicted and actual outputs
    star_test_predict_ESN = pamdemod(predictedTestOutput, M);
    star_test_ESN = pamdemod(testOutputSequence(nForgetPoints+1:end,:), M);

    % Calculate BER
    [~, ber] = biterr(star_test_predict_ESN, star_test_ESN);

    % Store BER for this value of nInternalUnits
   ber_esn_matrix(i) = ber;
    
    % Display current iteration information
    disp(['nInternalUnits = ' num2str(nInternalUnits(i)) ', BER = ' num2str(ber)]);
end

% Display BER values for each value of nInternalUnits
disp('BER for different values of nInternalUnits:');
disp(ber_esn_matrix);

%taps = 1 ber  = [ 0.1298    0.1103    0.1072    0.1116    0.0816     0.0917     0.0767     0.0757     0.0735     0.0665     0.0664]
%taps = 5 ber =  [ 0.0855    0.0709    0.0626    0.0580    0.0535     0.0492     0.0471     0.0475     0.0447     0.0428     0.0421]
%taps = 10 ber = [ 0.0471    0.0411    0.0372    0.0326    0.0339     0.0309     0.0309     0.0298     0.0274     0.0269     0.0261]
%taps = 15 ber = [ 0.0213    0.0177    0.0174    0.0160    0.0139     0.0133     0.0126     0.0119     0.0115     0.0112     0.0121]
%taps = 20 ber = [ 0.0156    0.0148    0.0120    0.0118    0.0127     0.0123     0.0121     0.0106     0.0111     0.0117     0.0119]
%taps = 25 ber = [ 0.0108    0.0084    0.0077    0.0077    0.0063     0.0061     0.0069     0.0082     0.0095     0.0089     0.0115]
%taps = 30 ber = [ 0.0095    0.0073    0.0059    0.0075    0.0067     0.0063     0.0078     0.0084     0.0075     0.0109     0.0135]
%taps = 35 ber = [ 0.0061    0.0046    0.0053    0.0045    0.0044     0.0049     0.0068     0.0061     0.0098     0.0108     0.0134]
%taps = 40 ber = [ 0.0048    0.0037    0.0030    0.0034    0.0054     0.0050     0.0059     0.0077     0.0110     0.0144     0.0219]


bermatrix1=[ 0.1298    0.1103    0.1072    0.1116    0.0816     0.0917     0.0767     0.0757     0.0735     0.0665     0.0664];
bermatrix2=[ 0.0855    0.0709    0.0626    0.0580    0.0535     0.0492     0.0471     0.0475     0.0447     0.0428     0.0421];
bermatrix3=[ 0.0471    0.0411    0.0372    0.0326    0.0339     0.0309     0.0309     0.0298     0.0274     0.0269     0.0261];
bermatrix4=[ 0.0213    0.0177    0.0174    0.0160    0.0139     0.0133     0.0126     0.0119     0.0115     0.0112     0.0121];
bermatrix5=[ 0.0156    0.0148    0.0120    0.0118    0.0127     0.0123     0.0121     0.0106     0.0111     0.0117     0.0119];
bermatrix6=[ 0.0108    0.0084    0.0077    0.0077    0.0063     0.0061     0.0069     0.0082     0.0095     0.0089     0.0115]; 
bermatrix7=[ 0.0095    0.0073    0.0059    0.0075    0.0067     0.0063     0.0078     0.0084     0.0075     0.0109     0.0135]; 
bermatrix8=[ 0.0061    0.0046    0.0053    0.0045    0.0044     0.0049     0.0068     0.0061     0.0098     0.0108     0.0134];
bermatrix9=[ 0.0048    0.0037    0.0030    0.0034    0.0054     0.0050     0.0059     0.0077     0.0110     0.0144     0.0219]; 


ber_matrix_esn = [bermatrix1; bermatrix2; bermatrix3; bermatrix4; bermatrix5; bermatrix6; bermatrix7; bermatrix8; bermatrix9];
tap_vector = [1 5 10 15 20 25 30 35 40];



X= nInternalUnits;
Y= tap_vector; 



% Plot heatmap
figure;
imagesc(X, Y, log10(ber_matrix_esn));
colorbar;

xlabel('nInternalUnits');
ylabel('Taps');

title('BER from ESN');


% Adjust x-axis limits
xticks(X);
yticks(Y);


% Set colorbar label
colorbarLabel = 'BER';
ylabel(colorbar, colorbarLabel);


figure;
heatmap(X, Y, log10(ber_matrix_esn));


xlabel('nInternalUnits');
ylabel('Taps');
title('BER from ESN');







end
