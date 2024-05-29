function [ber_esn,star_test_predict_ESN, star_test_ESN] = ESN(points_per_symbol,M,y,n_ignore,adc_rate,symbol_rate,number_of_symbols,photocurrent)
   
    




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

%%%% generate an esn 
nInputUnits = samples_per_symbol + 1;
nInternalUnits = 30;
nOutputUnits = 1;

% Create input scaling vector with (samples_per_symbol + 1) 0.1's
inputScalingVector = 0.1 * ones(nInputUnits, 1);

% Create input shift vector with zeros in the same amount as samples_per_symbol + 1
inputShiftVector = zeros(nInputUnits, 1);

esn = generate_esn(nInputUnits, nInternalUnits, nOutputUnits, ...
    'spectralRadius', 1.3, 'inputScaling', inputScalingVector, 'inputShift', inputShiftVector, ...
    'teacherScaling', 0.3, 'teacherShift', -0.2, 'feedbackScaling', 0, ...
    'type', 'plain_esn');


%%% VARIANTS YOU MAY WISH TO TRY OUT
% (Comment out the above "esn = ...", comment in one of the variants
% below)

% % Use a leaky integrator ESN
% esn = generate_esn(nInputUnits, nInternalUnits, nOutputUnits, ...
%     'spectralRadius',0.5,'inputScaling',[0.1;0.1],'inputShift',[0;0], ...
%     'teacherScaling',[0.3],'teacherShift',[-0.2],'feedbackScaling', 0, ...
%     'type', 'leaky_esn'); 
% 
% % Use a time-warping invariant ESN (makes little sense here, just for
% % demo's sake)
% esn = generate_esn(nInputUnits, nInternalUnits, nOutputUnits, ...
%     'spectralRadius',0.5,'inputScaling',[0.1;0.1],'inputShift',[0;0], ...
%     'teacherScaling',[0.3],'teacherShift',[-0.2],'feedbackScaling', 0, ...
%     'type', 'twi_esn'); 

% % Do online RLS learning instead of batch learning.
% esn = generate_esn(nInputUnits, nInternalUnits, nOutputUnits, ...
%       'spectralRadius',0.4,'inputScaling',[0.1;0.5],'inputShift',[0;1], ...
%       'teacherScaling',[0.3],'teacherShift',[-0.2],'feedbackScaling',0, ...
%       'learningMode', 'online' , 'RLS_lambda',0.9999995 , 'RLS_delta',0.000001, ...
%       'noiseLevel' , 0.00000000) ; 

esn.internalWeights = esn.spectralRadius * esn.internalWeights_UnitSR;






%%%% train the ESN
nForgetPoints = 100 ; % discard the first 100 points
[trainedEsn stateMatrix] = ...
    train_esn(trainInputSequence, trainOutputSequence, esn, nForgetPoints) ; 

%%%% save the trained ESN
% save_esn(trainedEsn, 'esn_narma_demo_1'); 

%%%% plot the internal states of 4 units
% nPoints = 200 ; 
% plot_states(stateMatrix,[1 2 3 4], nPoints, 1, 'traces of first 4 reservoir units') ; 

% compute the output of the trained ESN on the training and testing data,
% discarding the first nForgetPoints of each

nForgetPoints = 100 ; 
predictedTrainOutput = test_esn(trainInputSequence, trainedEsn, nForgetPoints);
predictedTestOutput =test_esn(testInputSequence,  trainedEsn, nForgetPoints); 





% % create input-output plots
% nPlotPoints = 100 ; 
% plot_sequence(trainOutputSequence(nForgetPoints+1:end,:), predictedTrainOutput, nPlotPoints,...
%     'training: teacher sequence (red) vs predicted sequence (blue)');
% plot_sequence(testOutputSequence(nForgetPoints+1:end,:), predictedTestOutput, nPlotPoints, ...
%    'testing: teacher sequence (red) vs predicted sequence (blue)') ; 
% 
% %%%%compute NRMSE training error
% %trainError = compute_NRMSE(predictedTrainOutput, trainOutputSequence); 
% %disp(sprintf('train NRMSE = %s', num2str(trainError)))
% 
% %%%%compute NRMSE testing error
% %testError = compute_NRMSE(predictedTestOutput, testOutputSequence); 
% %disp(sprintf('test NRMSE = %s', num2str(testError)))


star_test_predict_ESN = pamdemod(predictedTestOutput, M);
star_test_ESN = pamdemod(testOutputSequence(nForgetPoints+1:end,:), M);
    

[~,ber_esn] =  biterr(star_test_predict_ESN, star_test_ESN);


disp(sprintf('BER on testing data from ESN = %s', num2str(log10(ber_esn))));


%eyediagram(predictedTestOutput,2);


end
