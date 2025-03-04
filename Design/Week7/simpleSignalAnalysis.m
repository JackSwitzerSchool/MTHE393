% Simple script to analyze signals and noise without complex frequency analysis
clear all;
close all;

% Set up directories
freq_data_dir = 'C:\Users\jacks\Documents\Life\School\3rd Year\W2025\MTHE393\Design\freq_data';

% Get list of specific files in the freq_data directory
files = dir(fullfile(freq_data_dir, 'freq_*.mat'));

% Check if files exist
if isempty(files)
    error('No matching files found in freq_data directory.');
end

fprintf('Found %d signal files for analysis.\n', length(files));

% First pass: determine minimum signal length
min_length = inf;
for i = 1:length(files)
    data = load(fullfile(freq_data_dir, files(i).name));
    struct_name = fieldnames(data);
    main_struct = data.(struct_name{1});
    output_struct = main_struct.output;
    min_length = min(min_length, length(output_struct.signal));
end

fprintf('Minimum signal length across all files: %d samples\n', min_length);

% Initialize variables with known minimum length
all_signals = zeros(min_length, length(files));
time_values = [];

% Load all signals
fprintf('Loading signals...\n');
for i = 1:length(files)
    % Load file
    data = load(fullfile(freq_data_dir, files(i).name));
    struct_name = fieldnames(data);
    main_struct = data.(struct_name{1});
    output_struct = main_struct.output;
    
    if i == 1
        time_values = output_struct.time(1:min_length);
    end
    
    % Truncate signal to minimum length
    all_signals(:, i) = output_struct.signal(1:min_length);
    
    % Print progress
    if mod(i, 10) == 0
        fprintf('  Loaded %d of %d files\n', i, length(files));
    end
end

fprintf('All signals loaded successfully.\n');

% Calculate average signal (simple approach)
avg_signal = mean(all_signals, 2);

% Calculate noise for each signal as difference from average
noise_signals = all_signals - repmat(avg_signal, 1, size(all_signals, 2));

% Calculate average noise magnitude
avg_noise_magnitude = mean(abs(noise_signals(:)));
fprintf('Average noise magnitude: %.6f\n', avg_noise_magnitude);

% Calculate signal-to-noise ratio
signal_power = mean(avg_signal.^2);
noise_power = mean(mean(noise_signals.^2));
snr_value = 10*log10(signal_power/noise_power);
fprintf('Signal-to-Noise Ratio: %.2f dB\n', snr_value);

% Plot results
figure('Position', [100, 100, 900, 700]);

% Plot 1: All signals overlaid
subplot(3,1,1);
plot(time_values, all_signals, 'Color', [0.8, 0.8, 0.8], 'LineWidth', 0.5);
hold on;
plot(time_values, avg_signal, 'r', 'LineWidth', 2);
title('All Signals with Average');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;
legend('Individual Signals', 'Average Signal', 'Location', 'best');

% Plot 2: Average signal
subplot(3,1,2);
plot(time_values, avg_signal, 'b', 'LineWidth', 2);
title('Average Signal (Denoised)');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

% Plot 3: Noise example (from first signal)
subplot(3,1,3);
plot(time_values, noise_signals(:,1), 'g', 'LineWidth', 1.5);
title(sprintf('Noise Component (SNR: %.2f dB)', snr_value));
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

% Add overall title
sgtitle('Signal and Noise Analysis', 'FontSize', 14);

% Save the figure
savefig('simple_signal_analysis.fig');
saveas(gcf, 'simple_signal_analysis.png');

% Save the results
save('simple_signal_results.mat', 'time_values', 'avg_signal', 'noise_signals', 'snr_value');

fprintf('Analysis complete! Results saved.\n'); 