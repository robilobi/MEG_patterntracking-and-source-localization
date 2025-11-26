function [y_binned, t_binned] = fun_bin(y, t_original, samples_per_bin)
% bin size in sec
num_time_series = size(y, 1);  % Number of time series (N subjects)
% Preallocate binned data matrix
num_bins = floor(length(t_original) / samples_per_bin);  % Number of full bins
y_binned = zeros(num_time_series, num_bins);  % To store binned data

% Loop over each time series (each row in the matrix)
for j = 1:num_time_series % N subj
    for i = 1:num_bins    % expected N tones
        start_idx = (i-1) * samples_per_bin + 1;   % Start index of the current bin
        end_idx = i * samples_per_bin;             % End index of the current bin
        y_binned(j, i) = mean(y(j, start_idx:end_idx));  % Calculate the mean for the bin
    end
end

% Create the new binned time vector
% t_binned = linspace(0, 1, num_bins);  % Time vector for binned data
t_binned = 1:num_bins;  % Time vector for binned data





