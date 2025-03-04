% Low-Pass Filter Analysis Script
% This script focuses on applying an optimized low-pass filter to clean up signals

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

% Calculate sampling frequency
Fs = 1/mean(diff(time_values));
fprintf('Sampling frequency: %.2f Hz\n', Fs);

% Calculate average signal (pre-filtering)
avg_signal = mean(all_signals, 2);

% Create a structure to hold shared data (to avoid scope issues)
data = struct();
data.cutoff_freq = 10; % Hz - starting point
data.Fs = Fs;
data.time_values = time_values;
data.avg_signal = avg_signal;
data.all_signals = all_signals;

% Create figure for interactive cutoff frequency selection
fig = figure('Position', [100, 100, 1200, 800], 'Name', 'Low-Pass Filter Analysis');

% Create UI controls for adjusting cutoff frequency
data.text_label = uicontrol('Style', 'text', 'Position', [50, 20, 150, 20], 'String', 'Cutoff Frequency (Hz):');
data.edit_cutoff = uicontrol('Style', 'edit', 'Position', [200, 20, 60, 20], 'String', num2str(data.cutoff_freq));
data.slider_cutoff = uicontrol('Style', 'slider', 'Position', [270, 20, 200, 20], ...
                         'Min', 0.1, 'Max', Fs/4, 'Value', data.cutoff_freq, ...
                         'SliderStep', [0.01, 0.1]);

% Button to apply current filter settings
data.apply_button = uicontrol('Style', 'pushbutton', 'Position', [500, 20, 100, 20], ...
                         'String', 'Apply Filter');

% Button to save results
data.save_button = uicontrol('Style', 'pushbutton', 'Position', [620, 20, 100, 20], ...
                        'String', 'Save Results');

% Function to update the plot with new cutoff frequency
function updatePlot(data)
    cutoff = data.cutoff_freq;
    fs = data.Fs;
    time = data.time_values;
    avg_sig = data.avg_signal;
    
    % Apply low-pass filter with current cutoff
    [b, a] = butter(4, cutoff/(fs/2), 'low');
    filtered_sig = filtfilt(b, a, avg_sig);
    
    % Calculate frequency domain representation
    L = length(avg_sig);
    f = fs*(0:(L/2))/L;
    
    % FFT of original and filtered signals
    Y_orig = fft(avg_sig);
    P2_orig = abs(Y_orig/L);
    P1_orig = P2_orig(1:floor(L/2)+1);
    P1_orig(2:end-1) = 2*P1_orig(2:end-1);
    
    Y_filt = fft(filtered_sig);
    P2_filt = abs(Y_filt/L);
    P1_filt = P2_filt(1:floor(L/2)+1);
    P1_filt(2:end-1) = 2*P1_filt(2:end-1);
    
    % Plot time domain signals
    subplot(2,2,1);
    plot(time, avg_sig, 'b', 'LineWidth', 1);
    title('Original Average Signal');
    xlabel('Time (s)');
    ylabel('Amplitude');
    grid on;
    
    subplot(2,2,2);
    plot(time, filtered_sig, 'r', 'LineWidth', 1.5);
    title(sprintf('Low-Pass Filtered Signal (Cutoff: %.1f Hz)', cutoff));
    xlabel('Time (s)');
    ylabel('Amplitude');
    grid on;
    
    % Plot frequency domain
    subplot(2,2,3);
    loglog(f, P1_orig, 'b', 'LineWidth', 1);
    hold on;
    xline(cutoff, 'r--', 'LineWidth', 1.5);
    hold off;
    title('Frequency Spectrum - Original');
    xlabel('Frequency (Hz)');
    ylabel('Magnitude');
    grid on;
    xlim([0.1, fs/2]);
    
    subplot(2,2,4);
    loglog(f, P1_filt, 'r', 'LineWidth', 1);
    hold on;
    xline(cutoff, 'r--', 'LineWidth', 1.5);
    hold off;
    title('Frequency Spectrum - Filtered');
    xlabel('Frequency (Hz)');
    ylabel('Magnitude');
    grid on;
    xlim([0.1, fs/2]);
    
    % Add overall title
    sgtitle(sprintf('Low-Pass Filter Analysis (Cutoff: %.1f Hz)', cutoff), 'FontSize', 14);
end

% Callback function for slider
function updateSlider(hObject, ~, data)
    data.cutoff_freq = get(data.slider_cutoff, 'Value');
    set(data.edit_cutoff, 'String', num2str(data.cutoff_freq, '%.1f'));
    updatePlot(data);
end

% Callback function for edit box
function updateEdit(hObject, ~, data)
    new_cutoff = str2double(get(data.edit_cutoff, 'String'));
    if ~isnan(new_cutoff) && new_cutoff > 0 && new_cutoff < data.Fs/2
        data.cutoff_freq = new_cutoff;
        set(data.slider_cutoff, 'Value', new_cutoff);
        updatePlot(data);
    else
        % Reset to previous value if invalid
        set(data.edit_cutoff, 'String', num2str(get(data.slider_cutoff, 'Value'), '%.1f'));
    end
end

% Callback function for apply button
function applyFilter(hObject, ~, data)
    cutoff_freq = data.cutoff_freq;
    [b, a] = butter(4, cutoff_freq/(data.Fs/2), 'low');
    filtered_signal = filtfilt(b, a, data.avg_signal);
    
    % Create a new figure to show before/after comparison
    figure('Position', [150, 150, 1000, 600], 'Name', 'Before vs After Filtering');
    
    % Plot original signals with average
    subplot(2,1,1);
    plot(data.time_values, data.all_signals, 'Color', [0.8, 0.8, 0.8], 'LineWidth', 0.5);
    hold on;
    plot(data.time_values, data.avg_signal, 'b', 'LineWidth', 1.5);
    title('Original Signals with Average');
    xlabel('Time (s)');
    ylabel('Amplitude');
    grid on;
    
    % Plot filtered signal
    subplot(2,1,2);
    plot(data.time_values, filtered_signal, 'r', 'LineWidth', 2);
    title(sprintf('Low-Pass Filtered Signal (Cutoff: %.1f Hz)', cutoff_freq));
    xlabel('Time (s)');
    ylabel('Amplitude');
    grid on;
    
    % Calculate SNR
    noise = data.avg_signal - filtered_signal;
    snr_value = 10*log10(mean(filtered_signal.^2)/mean(noise.^2));
    subtitle(sprintf('SNR: %.2f dB', snr_value));
end

% Callback function for save button
function saveResults(hObject, ~, data)
    cutoff_freq = data.cutoff_freq;
    [b, a] = butter(4, cutoff_freq/(data.Fs/2), 'low');
    filtered_signal = filtfilt(b, a, data.avg_signal);
    
    % Save the filtered signal
    time_values = data.time_values;
    avg_signal = data.avg_signal;
    Fs = data.Fs;
    save('lowpass_filtered_signal.mat', 'time_values', 'avg_signal', 'filtered_signal', 'cutoff_freq', 'Fs');
    
    % Save the current figure
    savefig('lowpass_filter_analysis.fig');
    saveas(gcf, 'lowpass_filter_analysis.png');
    
    % Create and save a comparison figure
    figure('Position', [200, 200, 1000, 400], 'Name', 'Signal Comparison');
    plot(data.time_values, data.avg_signal, 'b', 'LineWidth', 1);
    hold on;
    plot(data.time_values, filtered_signal, 'r', 'LineWidth', 1.5);
    title(sprintf('Signal Before and After Low-Pass Filtering (Cutoff: %.1f Hz)', cutoff_freq));
    xlabel('Time (s)');
    ylabel('Amplitude');
    legend('Original Signal', 'Filtered Signal');
    grid on;
    
    savefig('signal_comparison.fig');
    saveas(gcf, 'signal_comparison.png');
    
    fprintf('Results saved successfully!\n');
end

% Set up callbacks with the data structure
set(data.slider_cutoff, 'Callback', {@updateSlider, data});
set(data.edit_cutoff, 'Callback', {@updateEdit, data});
set(data.apply_button, 'Callback', {@applyFilter, data});
set(data.save_button, 'Callback', {@saveResults, data});

% Initial plot
updatePlot(data);

fprintf('Low-pass filter analysis ready. Adjust the cutoff frequency using the slider or text box.\n');
fprintf('Click "Apply Filter" to see a detailed before/after comparison.\n');
fprintf('Click "Save Results" to save the filtered signal and figures.\n'); 