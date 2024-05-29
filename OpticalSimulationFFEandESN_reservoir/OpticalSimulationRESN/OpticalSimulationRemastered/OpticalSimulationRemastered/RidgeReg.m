function [ber,star_test_predict,star_test] = RidgeReg(M,X_for_network,y_for_network)
n_total_symbols = length(y_for_network);

    n_train = ceil(0.5* n_total_symbols);
    n_test = n_total_symbols - n_train;

    X_train = X_for_network(:, 1:n_train);
    X_test = X_for_network(:, 1 + n_train:n_train + n_test);

    y_train = y_for_network(1:n_train);
    y_test = y_for_network(1 + n_train:n_train + n_test);

    

    % Normalize the dataset 
    X_train_normalized =X_train;
    X_test_normalized = X_test;

    W=ridge(y_train',X_train_normalized',0.1);
    y_train_predict = W'*X_train_normalized;
    y_test_predict = W'*X_test_normalized;


    star_test_predict = pamdemod(y_test_predict,M);
    star_test = pamdemod(y_test,M);

    [~,ber] = biterr(star_test_predict,star_test);
    disp(sprintf('BER from ridge regretion = %s', num2str(ber)))
   
    %eyediagram(y_test_predict,2);
end

