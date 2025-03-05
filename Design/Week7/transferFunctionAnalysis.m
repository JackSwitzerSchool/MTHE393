% transferFunctionAnalysis.m
% This script uses the universal filter to denoise signals from the black box
% across a wide frequency range and generates a Bode plot to estimate the transfer function

clear all;
close all;

% Set up directories
base_dir = 'C:\Users\jacks\Documents\Life\School\3rd Year\W2025\MTHE393\Design\freq_data';
output_dir = 'C:\Users\jacks\Documents\Life\School\3rd Year\W2025\MTHE393\Design\Week7';

% Add path to make sure we can access the universal filter
if ~exist(fullfile(base_dir, 'applyUniversalFilter.m'), 'file')
    warning('Universal filter function not found. Using built-in filtering methods instead.');
    has_universal_filter = false;
else
    addpath(base_dir);
    has_universal_filter = true;
end

% Get list of all frequency files
files = dir(fullfile(base_dir, 'freq_*.mat'));

% Check if files exist
if isempty(files)
    error('No freq_*.mat files found. Run CopyScript.m first.');
end

fprintf('Found %d frequency files for analysis.\n', length(files));

% Initialize arrays to store results
frequencies = zeros(length(files), 1);
magnitudes = zeros(length(files), 1);
phases = zeros(length(files), 1);
filtering_success = true(length(files), 1); % Track which files were successfully filtered

% Suppress warnings for the filtering process to avoid cluttering the output
warning('off', 'MATLAB:singularMatrix');
warning('off', 'MATLAB:nearlySingularMatrix');

% Process each frequency file
for i = 1:length(files)
    % Load file
    file_path = fullfile(base_dir, files(i).name);
    data = load(file_path);
    struct_name = fieldnames(data);
    main_struct = data.(struct_name{1});
    output_struct = main_struct.output;
    input_struct = main_struct.input;
    
    % Extract signal and time values
    signal = output_struct.signal;
    time_values = output_struct.time;
    input_signal = input_struct.signal;
    
    % Extract the frequency from the input signal
    % The input is a sine wave of the form sin(w*t)
    try
        % Try to get frequency from the file name (more reliable)
        freq_str = files(i).name;
        % Extract numeric part from freq_XXXXXX.mat format
        freq_val = str2double(regexp(freq_str, 'freq_(\d+)', 'tokens', 'once'));
        if ~isnan(freq_val)
            % Convert back to actual frequency (we scaled by 1e6 when saving)
            frequencies(i) = freq_val / 1e6;
        else
            % Fallback: Estimate frequency from the signal
            frequencies(i) = estimateFrequency(input_signal, time_values);
        end
    catch
        % If that fails, estimate from the signal
        frequencies(i) = estimateFrequency(input_signal, time_values);
    end
    
    % Skip signals with zero or very low frequencies to avoid numerical issues
    if frequencies(i) < 1e-5
        fprintf('Skipping file %s due to extremely low frequency: %.8e Hz\n', files(i).name, frequencies(i));
        filtering_success(i) = false;
        continue;
    end
    
    % Attempt to filter the signal
    try
        % Use improved filtering method with more fallback options
        filtered_signal = improvedFilter(signal, time_values, frequencies(i), has_universal_filter);
        
        % Calculate magnitude and phase of the transfer function
        [mag, phase] = calculateTransferFunction(filtered_signal, input_signal, time_values, frequencies(i));
        
        % Store results
        magnitudes(i) = mag;
        phases(i) = phase;
        
        % Progress report
        if mod(i, 10) == 0 || i == length(files)
            fprintf('Processed %d/%d files (%.1f%%)\n', i, length(files), 100*i/length(files));
        end
    catch ME
        % If filtering fails, mark as unsuccessful
        filtering_success(i) = false;
        fprintf('Warning: Processing failed for frequency %.6e Hz: %s\n', frequencies(i), ME.message);
    end
end

% Restore warning state
warning('on', 'MATLAB:singularMatrix');
warning('on', 'MATLAB:nearlySingularMatrix');

% Remove any entries where filtering failed
valid_indices = filtering_success;
frequencies = frequencies(valid_indices);
magnitudes = magnitudes(valid_indices);
phases = phases(valid_indices);

% Sort by frequency for proper plotting
[frequencies, sort_idx] = sort(frequencies);
magnitudes = magnitudes(sort_idx);
phases = phases(sort_idx);

% Convert magnitudes to dB
magnitudes_db = 20 * log10(magnitudes);

% Make sure phases are in the range [-180, 180]
phases = mod(phases + 180, 360) - 180;

% Create Bode plot
figure('Position', [100, 100, 900, 700], 'Name', 'Bode Plot');

% Magnitude plot
subplot(2, 1, 1);
semilogx(frequencies, magnitudes_db, 'o-', 'LineWidth', 1.5);
grid on;
title('Bode Plot - Magnitude');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');

% Phase plot
subplot(2, 1, 2);
semilogx(frequencies, phases, 'o-', 'LineWidth', 1.5);
grid on;
title('Bode Plot - Phase');
xlabel('Frequency (Hz)');
ylabel('Phase (degrees)');

% Add overall title
sgtitle('System Transfer Function', 'FontSize', 16);

% Save the figure
save_path = fullfile(output_dir, 'bode_plot');
savefig([save_path, '.fig']);
saveas(gcf, [save_path, '.png']);

% Estimate transfer function using simpler method (without requiring tfest)
fprintf('\nEstimating transfer function from frequency response data...\n');

% Prepare complex frequency response data
w = 2*pi*frequencies;  % Angular frequencies
h = magnitudes .* exp(1j * deg2rad(phases));  % Complex frequency response

% Try different orders to find the best fit
max_num_order = 5;   % Maximum numerator order
max_den_order = 5;   % Maximum denominator order
best_fit_error = inf;
best_num = [];
best_den = [];
best_orders = [1, 1];  % Default [num_order, den_order]

fprintf('Testing different transfer function orders...\n');

for num_order = 0:max_num_order
    for den_order = 1:max_den_order
        if den_order >= num_order  % Ensure proper transfer function (poles >= zeros)
            try
                % Use invfreqs to find the transfer function coefficients
                % This is more basic than tfest but doesn't require System Identification Toolbox
                [b, a] = invfreqs(h, w, num_order, den_order);
                
                % Evaluate the transfer function at the original frequencies
                h_model = freqs(b, a, w);
                
                % Calculate the fit error
                fit_error = norm(h - h_model) / norm(h);
                
                fprintf('  Testing with %d zeros, %d poles - fit error: %.4f\n', num_order, den_order, fit_error);
                
                % Update if this is the best fit so far
                if fit_error < best_fit_error
                    best_fit_error = fit_error;
                    best_num = b;
                    best_den = a;
                    best_orders = [num_order, den_order];
                    fprintf('  New best fit: %d zeros, %d poles, fit error: %.4f\n', num_order, den_order, fit_error);
                end
            catch ME
                fprintf('  Fitting with %d zeros, %d poles failed: %s\n', num_order, den_order, ME.message);
            end
        end
    end
end

% If a valid transfer function was found, plot and save it
if ~isempty(best_num) && ~isempty(best_den)
    fprintf('\nBest transfer function estimate:\n');
    fprintf('  %d zeros, %d poles\n', best_orders(1), best_orders(2));
    
    % Create transfer function object
    sys = tf(best_num, best_den);
    
    % Display the transfer function
    disp(sys);
    
    % Create a more detailed frequency vector for smooth plotting
    w_dense = logspace(log10(min(w)), log10(max(w)), 1000);
    f_dense = w_dense / (2*pi);
    
    % Evaluate the frequency response at the dense frequencies
    h_dense = freqs(best_num, best_den, w_dense);
    mag_dense = abs(h_dense);
    phase_dense = rad2deg(angle(h_dense));
    mag_db_dense = 20 * log10(mag_dense);
    
    % Compare frequency responses
    figure('Position', [150, 150, 900, 700], 'Name', 'Transfer Function Fit');
    
    % Plot magnitude comparison
    subplot(2, 1, 1);
    semilogx(frequencies, magnitudes_db, 'o', 'LineWidth', 1.5);
    hold on;
    semilogx(f_dense, mag_db_dense, '-', 'LineWidth', 1.5);
    grid on;
    title('Magnitude Response - Data vs. Model');
    legend('Measured Data', 'Transfer Function Model');
    xlabel('Frequency (Hz)');
    ylabel('Magnitude (dB)');
    
    % Plot phase comparison
    subplot(2, 1, 2);
    semilogx(frequencies, phases, 'o', 'LineWidth', 1.5);
    hold on;
    semilogx(f_dense, phase_dense, '-', 'LineWidth', 1.5);
    grid on;
    title('Phase Response - Data vs. Model');
    legend('Measured Data', 'Transfer Function Model');
    xlabel('Frequency (Hz)');
    ylabel('Phase (degrees)');
    
    % Add overall title
    sgtitle('Transfer Function Model Fit', 'FontSize', 16);
    
    % Save the figure
    save_path = fullfile(output_dir, 'transfer_function_fit');
    savefig([save_path, '.fig']);
    saveas(gcf, [save_path, '.png']);
    
    % Save the transfer function model
    transfer_function_data = struct();
    transfer_function_data.num = best_num;
    transfer_function_data.den = best_den;
    transfer_function_data.sys = sys;
    transfer_function_data.frequencies = frequencies;
    transfer_function_data.magnitudes = magnitudes;
    transfer_function_data.phases = phases;
    transfer_function_data.fit_error = best_fit_error;
    
    save(fullfile(output_dir, 'transfer_function_model.mat'), 'transfer_function_data');
    
    % Generate code for the transfer function
    fprintf('\nTransfer function in code form:\n');
    fprintf('num = [');
    fprintf(' %g', best_num);
    fprintf(' ];\n');
    fprintf('den = [');
    fprintf(' %g', best_den);
    fprintf(' ];\n');
    fprintf('sys = tf(num, den);\n');
else
    fprintf('\nUnable to find a suitable transfer function model.\n');
end

% Create a simple text report
fid = fopen(fullfile(output_dir, 'transfer_function_report.txt'), 'w');
fprintf(fid, 'TRANSFER FUNCTION ANALYSIS REPORT\n');
fprintf(fid, '================================\n\n');
fprintf(fid, 'Analysis performed on %s\n\n', datestr(now));
fprintf(fid, 'Number of frequency points analyzed: %d\n', length(frequencies));
fprintf(fid, 'Frequency range: %.8e Hz to %.8e Hz\n\n', min(frequencies), max(frequencies));

if ~isempty(best_num) && ~isempty(best_den)
    fprintf(fid, 'Best transfer function estimate:\n');
    fprintf(fid, '  %d zeros, %d poles\n', best_orders(1), best_orders(2));
    fprintf(fid, '  Fit error: %.4f\n\n', best_fit_error);
    
    fprintf(fid, 'Transfer function in code form:\n');
    fprintf(fid, 'num = [');
    fprintf(fid, ' %g', best_num);
    fprintf(fid, ' ];\n');
    fprintf(fid, 'den = [');
    fprintf(fid, ' %g', best_den);
    fprintf(fid, ' ];\n');
    fprintf(fid, 'sys = tf(num, den);\n');
else
    fprintf(fid, 'No suitable transfer function model found.\n');
end
fclose(fid);

fprintf('\nAnalysis complete! Results saved in %s\n', output_dir);

% Helper function for improved filtering with multiple fallback options
function filtered_signal = improvedFilter(signal, time_values, frequency, has_universal_filter)
    % Calculate sampling frequency
    Fs = 1/mean(diff(time_values));
    
    % Choose appropriate filtering method based on frequency range
    if frequency < 0.01
        % For very low frequencies, direct filtering can be unstable
        % Use a simple moving average with a wide window
        window_size = min(round(Fs/(frequency*2)), round(length(signal)/10));
        window_size = max(window_size, 3); % Ensure minimum window size
        filtered_signal = smoothdata(signal, 'movmean', window_size);
        return;
    end
    
    % For normal frequency ranges, try multiple approaches
    filter_approaches = {'universal', 'butterworth', 'movmean', 'savgol', 'median'};
    
    % If universal filter is not available, skip it
    if ~has_universal_filter
        filter_approaches = filter_approaches(2:end);
    end
    
    % Try each approach in order until one works without errors
    for approach_idx = 1:length(filter_approaches)
        approach = filter_approaches{approach_idx};
        
        try
            switch approach
                case 'universal'
                    % Try universal filter from previous analysis
                    filtered_signal = applyUniversalFilter(signal, time_values, frequency);
                    
                case 'butterworth'
                    % Use a Butterworth filter with conservative parameters
                    cutoff = min(frequency * 2, Fs/2 * 0.8); % More conservative cutoff
                    order = 2; % Lower order for better stability
                    [b, a] = butter(order, cutoff/(Fs/2), 'low');
                    filtered_signal = filtfilt(b, a, signal);
                    
                case 'movmean'
                    % Simple moving average
                    window_size = max(3, round(Fs/(frequency*10)));
                    filtered_signal = smoothdata(signal, 'movmean', window_size);
                    
                case 'savgol'
                    % Savitzky-Golay filter (polynomial smoothing)
                    window_size = max(9, 2*round(Fs/(frequency*20))+1);
                    window_size = min(window_size, length(signal)-1);
                    if mod(window_size, 2) == 0
                        window_size = window_size + 1; % Ensure odd window size
                    end
                    filtered_signal = sgolayfilt(signal, 3, window_size);
                    
                case 'median'
                    % Median filter (good for removing outliers)
                    window_size = max(3, round(Fs/(frequency*20)));
                    filtered_signal = medfilt1(signal, window_size);
            end
            
            % Check for NaN or Inf values
            if any(isnan(filtered_signal)) || any(isinf(filtered_signal))
                error('Filter produced NaN or Inf values');
            end
            
            % If we got here, filtering was successful
            return;
        catch
            % This approach failed, try the next one
            continue;
        end
    end
    
    % If all approaches failed, use the original signal with minimal smoothing
    fprintf('  Warning: All filtering approaches failed. Using minimal smoothing.\n');
    filtered_signal = smoothdata(signal, 'gaussian', 3);
end

% Helper function to calculate transfer function (magnitude and phase)
function [magnitude, phase] = calculateTransferFunction(output_signal, input_signal, time_values, frequency)
    % Calculate sampling frequency
    Fs = 1/mean(diff(time_values));
    
    % Calculate FFT of input and output signals
    N = length(input_signal);
    input_fft = fft(input_signal);
    output_fft = fft(output_signal);
    
    % Find the index corresponding to the input frequency
    freq_resolution = Fs/N;
    freq_idx = round(frequency/freq_resolution) + 1;
    
    % Ensure we're in range
    freq_idx = min(freq_idx, floor(N/2) + 1);
    
    % Calculate magnitude and phase at the frequency of interest
    input_component = input_fft(freq_idx);
    output_component = output_fft(freq_idx);
    
    % Calculate transfer function
    transfer = output_component / input_component;
    
    % Extract magnitude and phase
    magnitude = abs(transfer);
    phase = rad2deg(angle(transfer));
end

% Helper function to estimate the frequency of a sine wave
function freq = estimateFrequency(signal, time_values)
    % Calculate sampling frequency
    Fs = 1/mean(diff(time_values));
    
    % Calculate FFT
    N = length(signal);
    Y = fft(signal);
    P2 = abs(Y/N);
    P1 = P2(1:floor(N/2)+1);
    P1(2:end-1) = 2*P1(2:end-1);
    
    % Define frequency vector
    f = Fs*(0:(N/2))/N;
    
    % Find peak frequency (excluding DC component)
    [~, idx] = max(P1(2:end));
    freq = f(idx + 1); % +1 because we excluded the DC component
end