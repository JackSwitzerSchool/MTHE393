% Enhanced script to analyze signals with advanced denoising techniques
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

% Method 1: Simple averaging
avg_signal = mean(all_signals, 2);

% Method 2: Moving average filter
window_size = round(0.01 * Fs); % 10ms window
b = (1/window_size)*ones(1, window_size);
a = 1;
smoothed_signal = filtfilt(b, a, avg_signal);

% Method 3: Low-pass filter
cutoff_freq = 50; % Hz - adjust based on your expected signal bandwidth
[b, a] = butter(4, cutoff_freq/(Fs/2), 'low');
filtered_signal = filtfilt(b, a, avg_signal);

% Method 4: Savitzky-Golay filter (polynomial smoothing)
sg_signal = sgolayfilt(avg_signal, 3, 51);

% Method 5: Wavelet denoising
level = 5;
wname = 'sym8';
[wavelet_signal, ~] = wdenoise(avg_signal, level, 'Wavelet', wname, 'DenoisingMethod', 'UniversalThreshold');

% Calculate noise for each denoising method
noise_avg = all_signals(:,1) - avg_signal;
noise_smooth = all_signals(:,1) - smoothed_signal;
noise_filter = all_signals(:,1) - filtered_signal;
noise_sg = all_signals(:,1) - sg_signal;
noise_wavelet = all_signals(:,1) - wavelet_signal;

% Calculate SNR for each method
snr_avg = 10*log10(mean(avg_signal.^2)/mean(noise_avg.^2));
snr_smooth = 10*log10(mean(smoothed_signal.^2)/mean(noise_smooth.^2));
snr_filter = 10*log10(mean(filtered_signal.^2)/mean(noise_filter.^2));
snr_sg = 10*log10(mean(sg_signal.^2)/mean(noise_sg.^2));
snr_wavelet = 10*log10(mean(wavelet_signal.^2)/mean(noise_wavelet.^2));

fprintf('\nSignal-to-Noise Ratio for different methods:\n');
fprintf('  Simple averaging: %.2f dB\n', snr_avg);
fprintf('  Moving average: %.2f dB\n', snr_smooth);
fprintf('  Low-pass filter: %.2f dB\n', snr_filter);
fprintf('  Savitzky-Golay: %.2f dB\n', snr_sg);
fprintf('  Wavelet denoising: %.2f dB\n', snr_wavelet);

% Find the best method based on SNR
snr_values = [snr_avg, snr_smooth, snr_filter, snr_sg, snr_wavelet];
[best_snr, best_idx] = max(snr_values);
method_names = {'Simple averaging', 'Moving average', 'Low-pass filter', 'Savitzky-Golay', 'Wavelet denoising'};
best_method = method_names{best_idx};
fprintf('\nBest denoising method: %s (SNR: %.2f dB)\n', best_method, best_snr);

% Get the best signal
switch best_idx
    case 1
        best_signal = avg_signal;
    case 2
        best_signal = smoothed_signal;
    case 3
        best_signal = filtered_signal;
    case 4
        best_signal = sg_signal;
    case 5
        best_signal = wavelet_signal;
end

% Try to fit a simple function to the signal
% First, normalize time to [0,1] for better fitting
norm_time = (time_values - min(time_values)) / (max(time_values) - min(time_values));

% Try different function types
fprintf('\nFitting mathematical functions to the signal...\n');

% Sine wave fit
sine_model = @(p,t) p(1)*sin(2*pi*p(2)*t + p(3)) + p(4);
sine_p0 = [1, 5, 0, 0]; % Initial guess: [amplitude, frequency, phase, offset]
sine_options = optimoptions('lsqcurvefit', 'Display', 'off');
try
    sine_params = lsqcurvefit(sine_model, sine_p0, norm_time, best_signal, [], [], sine_options);
    sine_fit = sine_model(sine_params, norm_time);
    sine_rmse = sqrt(mean((sine_fit - best_signal).^2));
    fprintf('  Sine wave fit RMSE: %.6f\n', sine_rmse);
catch
    sine_fit = zeros(size(best_signal));
    sine_rmse = inf;
    fprintf('  Sine wave fit failed\n');
end

% Polynomial fit
poly_degree = 10;
poly_params = polyfit(norm_time, best_signal, poly_degree);
poly_fit = polyval(poly_params, norm_time);
poly_rmse = sqrt(mean((poly_fit - best_signal).^2));
fprintf('  Polynomial (degree %d) fit RMSE: %.6f\n', poly_degree, poly_rmse);

% Exponential fit
exp_model = @(p,t) p(1)*exp(p(2)*t) + p(3);
exp_p0 = [1, -1, 0]; % Initial guess: [scale, decay, offset]
try
    exp_params = lsqcurvefit(exp_model, exp_p0, norm_time, best_signal, [], [], sine_options);
    exp_fit = exp_model(exp_params, norm_time);
    exp_rmse = sqrt(mean((exp_fit - best_signal).^2));
    fprintf('  Exponential fit RMSE: %.6f\n', exp_rmse);
catch
    exp_fit = zeros(size(best_signal));
    exp_rmse = inf;
    fprintf('  Exponential fit failed\n');
end

% Find the best fit
fit_rmse = [sine_rmse, poly_rmse, exp_rmse];
[best_fit_rmse, best_fit_idx] = min(fit_rmse);
fit_names = {'Sine wave', 'Polynomial', 'Exponential'};
best_fit_name = fit_names{best_fit_idx};
fprintf('\nBest function fit: %s (RMSE: %.6f)\n', best_fit_name, best_fit_rmse);

% Get the best fit
switch best_fit_idx
    case 1
        best_fit = sine_fit;
        if sine_params(2) > 0
            fit_equation = sprintf('y = %.4f*sin(2π*%.4f*t + %.4f) + %.4f', ...
                sine_params(1), sine_params(2), sine_params(3), sine_params(4));
        end
    case 2
        best_fit = poly_fit;
        fit_equation = 'y = polynomial (degree 10)';
    case 3
        best_fit = exp_fit;
        if exp_params(2) ~= 0
            fit_equation = sprintf('y = %.4f*exp(%.4f*t) + %.4f', ...
                exp_params(1), exp_params(2), exp_params(3));
        end
end

% Plot results
figure('Position', [100, 100, 1000, 800]);

% Plot 1: All signals with average
subplot(3,2,1);
plot(time_values, all_signals, 'Color', [0.8, 0.8, 0.8], 'LineWidth', 0.5);
hold on;
plot(time_values, avg_signal, 'r', 'LineWidth', 1.5);
title('All Signals with Average');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

% Plot 2: Comparison of denoising methods
subplot(3,2,2);
plot(time_values, avg_signal, 'LineWidth', 1);
hold on;
plot(time_values, smoothed_signal, 'LineWidth', 1);
plot(time_values, filtered_signal, 'LineWidth', 1);
plot(time_values, sg_signal, 'LineWidth', 1);
plot(time_values, wavelet_signal, 'LineWidth', 1);
title('Comparison of Denoising Methods');
xlabel('Time (s)');
ylabel('Amplitude');
legend('Average', 'Moving Avg', 'Low-pass', 'S-G', 'Wavelet', 'Location', 'best');
grid on;

% Plot 3: Best denoised signal
subplot(3,2,3);
plot(time_values, best_signal, 'b', 'LineWidth', 2);
title(['Best Denoised Signal: ' best_method]);
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

% Plot 4: Function fits
subplot(3,2,4);
plot(time_values, best_signal, 'b', 'LineWidth', 1.5);
hold on;
plot(time_values, sine_fit, 'r', 'LineWidth', 1);
plot(time_values, poly_fit, 'g', 'LineWidth', 1);
plot(time_values, exp_fit, 'm', 'LineWidth', 1);
title('Function Fits');
xlabel('Time (s)');
ylabel('Amplitude');
legend('Signal', 'Sine', 'Polynomial', 'Exponential', 'Location', 'best');
grid on;

% Plot 5: Best fit
subplot(3,2,5);
plot(time_values, best_signal, 'b', 'LineWidth', 1.5);
hold on;
plot(time_values, best_fit, 'r', 'LineWidth', 2);
title(['Best Fit: ' best_fit_name]);
if exist('fit_equation', 'var')
    subtitle(fit_equation);
end
xlabel('Time (s)');
ylabel('Amplitude');
legend('Denoised Signal', 'Function Fit', 'Location', 'best');
grid on;

% Plot 6: Residual noise
subplot(3,2,6);
residual = best_signal - best_fit;
plot(time_values, residual, 'g', 'LineWidth', 1);
title('Residual (Signal - Fit)');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

% Add overall title
sgtitle('Enhanced Signal Analysis', 'FontSize', 14);

% Save the figure
savefig('enhanced_signal_analysis.fig');
saveas(gcf, 'enhanced_signal_analysis.png');

% Save the results
save('enhanced_signal_results.mat', 'time_values', 'best_signal', 'best_fit', ...
    'best_method', 'best_fit_name', 'fit_equation', 'snr_values', 'fit_rmse');

fprintf('Analysis complete! Results saved.\n'); 