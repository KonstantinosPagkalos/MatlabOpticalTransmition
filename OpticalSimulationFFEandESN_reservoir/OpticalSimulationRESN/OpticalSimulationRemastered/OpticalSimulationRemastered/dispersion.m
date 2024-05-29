sps = 4;
n_symbols = 40000;

X = randn(sps, n_symbols);
y = randi(3, 1, n_symbols);

taps = 100;

tap_range = 1:taps;
m = floor((1 + taps)/2);
tap_range = tap_range - m;


X_tapped = zeros(sps*taps, n_symbols);

for i = m:n_symbols-m
    
    surrounding_elements = X(:, i + tap_range);
    vector = reshape(surrounding_elements, 1, taps*sps);
    X_tapped(:, i) = vector;
    
end

n_ignore = 1000;

X_for_network = X_tapped(:, n_ignore:end-n_ignore);
y_for_network = y(n_ignore:end-n_ignore);

n_total_symbols = length(y_for_network);

n_train = ceil(0.75*n_total_symbols);
n_test = n_total_symbols - n_train;

X_train = X_for_network(:, 1:n_train);
X_test = X_for_network(:, end - n_test + 1:end);

y_train = y_for_network(1:n_train);
y_test = y_for_network(end - n_test + 1:end);













