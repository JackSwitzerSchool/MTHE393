% Get list of specific files in the current folder
files = dir('file_name*.mat');  % Matches file_name1.mat, file_name2.mat, etc.

% Check if files exist
if isempty(files)
    error('No matching files found.');
end

% Initialize variables
all_signals = [];
time_values = [];

% Loop through each file
for i = 1:length(files)
    % Load file
    data = load(files(i).name);
    
    % Dynamically get the struct field name
    struct_name = fieldnames(data); % Extract struct field name
    main_struct = data.(struct_name{1}); % Access the main 1x1 struct
    
    % Extract the output struct (which contains time and signal)
    output_struct = main_struct.output; 

    if i == 1
        time_values = output_struct.time; % Extract time from the first file
        all_signals = zeros(length(time_values), length(files)); % Preallocate
    end
    
    % Store the signal data
    all_signals(:, i) = output_struct.signal;
end

% Compute the mean signal
mean_signal = mean(all_signals, 2);

pure_noise = file_name13.output.signal - mean_signal

% Plot the averaged graph
figure;
plot(time_values, pure_noise, 'b', 'LineWidth', 2);
xlabel('Time');
ylabel('Signal');
title('Averaged Signal');
grid on;

save('pure_noise.mat', 'time_values', 'pure_noise');  % Save the time and signal data


