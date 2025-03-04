% Set up directories
freq_data_dir = 'C:\Users\jacks\Documents\Life\School\3rd Year\W2025\MTHE393\Design\freq_data';
results_dir = fullfile(freq_data_dir, 'results');

% Create results directory if it doesn't exist
if ~exist(results_dir, 'dir')
    mkdir(results_dir);
end

% Get list of specific files in the freq_data directory
files = dir(fullfile(freq_data_dir, 'freq_*.mat'));

% Check if files exist
if isempty(files)
    error('No matching files found in freq_data directory.');
end

fprintf('Found %d frequency response files for analysis.\n', length(files));

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
frequencies = zeros(length(files), 1);

% Second pass: load and truncate signals
fprintf('Loading and processing signals...\n');
for i = 1:length(files)
    % Extract frequency from filename
    filename = files(i).name;
    freq_str = filename(5:end-4);  % Remove 'freq_' and '.mat'
    
    % Debug: Print the filename and extracted frequency string
    fprintf('File %d: %s, Extracted freq_str: %s\n', i, filename, freq_str);
    
    % Try to convert to number, with validation
    freq_val = str2double(freq_str);
    
    % Check if conversion was successful
    if isnan(freq_val)
        fprintf('WARNING: Could not convert "%s" to a number for file %s\n', freq_str, filename);
        % Try alternative extraction method
        parts = strsplit(filename, '_');
        if length(parts) > 1
            freq_str = parts{2};
            freq_str = strrep(freq_str, '.mat', '');
            fprintf('  Trying alternative extraction: %s\n', freq_str);
            freq_val = str2double(freq_str);
        end
    end
    
    % If still NaN, use a placeholder based on file index
    if isnan(freq_val)
        fprintf('  Still NaN, using index-based placeholder\n');
        freq_val = i; % Use file index as placeholder
    else
        % Convert from scaled integer back to original frequency
        freq_val = freq_val / 1e6;
    end
    
    frequencies(i) = freq_val;
    
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
end

% Check for any remaining NaN values
nan_count = sum(isnan(frequencies));
if nan_count > 0
    fprintf('WARNING: %d frequency values are still NaN. Replacing with sequence.\n', nan_count);
    nan_indices = isnan(frequencies);
    frequencies(nan_indices) = (1:sum(nan_indices)) / 1e6; % Replace with small values
end

% Sort signals by frequency
[frequencies, sort_idx] = sort(frequencies);
all_signals = all_signals(:, sort_idx);

fprintf('Frequency range analyzed: %.6e to %.6e rad/s\n', min(frequencies), max(frequencies));

% Compute frequency response (magnitude)
signal_magnitudes = max(abs(all_signals));

% Find dominant frequencies using peak detection
[peaks, peak_locs] = findpeaks(signal_magnitudes, 'MinPeakProminence', mean(signal_magnitudes));
dominant_freqs = frequencies(peak_locs);

% Print information about dominant frequencies
fprintf('\n===== FREQUENCY RESPONSE ANALYSIS =====\n');
fprintf('Detected %d dominant frequencies in the system response:\n', length(dominant_freqs));
for i = 1:length(dominant_freqs)
    fprintf('  Peak %d: %.6e rad/s (%.2f Hz) with magnitude %.4f\n', ...
        i, dominant_freqs(i), dominant_freqs(i)/(2*pi), peaks(i));
end

% Calculate system characteristics
if ~isempty(dominant_freqs)
    natural_freq = dominant_freqs(1);  % Assuming first peak is the natural frequency
    fprintf('\nSystem characteristics:\n');
    fprintf('  Estimated natural frequency: %.6e rad/s (%.2f Hz)\n', ...
        natural_freq, natural_freq/(2*pi));
    
    % If there are multiple peaks, calculate bandwidth
    if length(dominant_freqs) > 1
        bandwidth = max(dominant_freqs) - min(dominant_freqs);
        fprintf('  System bandwidth: %.6e rad/s (%.2f Hz)\n', ...
            bandwidth, bandwidth/(2*pi));
    end
end

% Reconstruct signal using only dominant frequencies
reconstructed_signal = zeros(size(time_values));
for i = 1:length(peak_locs)
    freq_idx = peak_locs(i);
    reconstructed_signal = reconstructed_signal + all_signals(:, freq_idx);
end
reconstructed_signal = reconstructed_signal / length(peak_locs);  % Normalize

% Calculate noise as difference between original and reconstructed
noise = all_signals(:, 1) - reconstructed_signal;  % Using first signal as reference

% Calculate SNR
snr_value = 10*log10(var(all_signals(:,1))/var(noise));
fprintf('  Signal-to-Noise Ratio: %.2f dB\n', snr_value);

% Calculate noise statistics
noise_rms = rms(noise);
noise_peak = max(abs(noise));
fprintf('  Noise RMS: %.6f\n', noise_rms);
fprintf('  Noise Peak: %.6f\n', noise_peak);
fprintf('  Peak-to-RMS ratio: %.2f\n', noise_peak/noise_rms);

fprintf('\nGenerating plots and saving results...\n');

% Plot frequency response
figure(1);
semilogx(frequencies, signal_magnitudes, 'b-', 'LineWidth', 1.5);
hold on;
semilogx(frequencies(peak_locs), peaks, 'ro', 'MarkerSize', 10);
xlabel('Frequency (rad/s)');
ylabel('Magnitude');
title('Frequency Response with Dominant Frequencies');
grid on;

% Add text labels for dominant frequencies
for i = 1:length(peak_locs)
    text(dominant_freqs(i), peaks(i)*1.05, ...
        sprintf('%.2e rad/s', dominant_freqs(i)), ...
        'FontSize', 8, 'HorizontalAlignment', 'center');
end

% Add legend
legend('Frequency Response', 'Dominant Frequencies', 'Location', 'best');

savefig(fullfile(results_dir, 'frequency_response.fig'));
saveas(gcf, fullfile(results_dir, 'frequency_response.png'));

% Plot original, reconstructed, and noise signals
figure(2);
subplot(3,1,1);
plot(time_values, all_signals(:,1), 'b', 'LineWidth', 1.5);
title('Original Signal');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

subplot(3,1,2);
plot(time_values, reconstructed_signal, 'g', 'LineWidth', 1.5);
title(sprintf('Reconstructed Signal (Denoised) - Using %d dominant frequencies', length(dominant_freqs)));
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

subplot(3,1,3);
plot(time_values, noise, 'r', 'LineWidth', 1.5);
title(sprintf('Noise Component (SNR: %.2f dB)', snr_value));
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

set(gcf, 'Position', [100, 100, 800, 900]);
sgtitle('Signal Decomposition Analysis');
savefig(fullfile(results_dir, 'signal_decomposition.fig'));
saveas(gcf, fullfile(results_dir, 'signal_decomposition.png'));

% Save the results
save(fullfile(results_dir, 'denoised_results.mat'), 'time_values', 'reconstructed_signal', 'noise', 'frequencies', 'signal_magnitudes', 'dominant_freqs', 'snr_value');

fprintf('Analysis complete! Results saved to %s\n', results_dir);


