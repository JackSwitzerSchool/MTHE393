% Script to visualize and analyze noise in detail

% Path to the averaged signal data
data_path = 'C:\Users\jacks\Documents\Life\School\3rd Year\W2025\MTHE393\Design\Week7\averaged_signal_data.mat';

% Check if the file exists
if ~exist(data_path, 'file')
    error(['File not found: ' data_path '. Run saveAveragedData.m first.']);
end

% Load the data
load(data_path);

% Extract noise and time data
noise = averaged_signal_data.noise;
time = averaged_signal_data.time;

% Create a figure for time-domain noise analysis
figure('Position', [100, 100, 1000, 800], 'Name', 'Noise Analysis');

% Plot 1: Raw noise signal
subplot(3,2,1);
plot(time, noise, 'r', 'LineWidth', 1);
title('Raw Noise Signal');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

% Plot 2: Noise histogram with normal distribution fit
subplot(3,2,2);
histogram(noise, 50, 'Normalization', 'pdf');
hold on;
% Fit normal distribution
pd = fitdist(noise, 'Normal');
x = linspace(min(noise), max(noise), 1000);
y = pdf(pd, x);
plot(x, y, 'r', 'LineWidth', 2);
title(sprintf('Noise Distribution (μ=%.4f, σ=%.4f)', pd.mu, pd.sigma));
xlabel('Amplitude');
ylabel('Probability Density');
grid on;
legend('Histogram', 'Normal Fit');

% Plot 3: Noise autocorrelation
subplot(3,2,3);
[acf, lags] = xcorr(noise, 'coeff');
plot(lags, acf, 'b');
title('Noise Autocorrelation');
xlabel('Lag');
ylabel('Autocorrelation');
xlim([-100, 100]);  % Focus on central region
grid on;

% Plot 4: Noise power spectral density
subplot(3,2,4);
Fs = 1/mean(diff(time));  % Sampling frequency
[pxx, f] = pwelch(noise, [], [], [], Fs);
plot(f, 10*log10(pxx), 'k');
title('Noise Power Spectral Density');
xlabel('Frequency (Hz)');
ylabel('Power/Frequency (dB/Hz)');
grid on;

% Plot 5: Cumulative energy of noise
subplot(3,2,5);
energy = cumsum(noise.^2);
energy = energy / energy(end);  % Normalize
plot(time, energy, 'g', 'LineWidth', 1.5);
title('Cumulative Energy of Noise');
xlabel('Time (s)');
ylabel('Normalized Cumulative Energy');
grid on;

% Plot 6: Noise spectrogram
subplot(3,2,6);
spectrogram(noise, 256, 250, 256, Fs, 'yaxis');
title('Noise Spectrogram');
colorbar;

% Adjust the layout
sgtitle('Detailed Noise Analysis', 'FontSize', 14, 'FontWeight', 'bold');

% Create a second figure for noise vs. signal comparison
figure('Position', [200, 200, 900, 600], 'Name', 'Noise vs. Signal');

% Plot 1: Original signal and noise overlay
subplot(2,1,1);
plot(time, averaged_signal_data.original_signal, 'b', 'LineWidth', 1.5);
hold on;
plot(time, noise, 'r', 'LineWidth', 0.8);
title('Original Signal vs. Noise');
xlabel('Time (s)');
ylabel('Amplitude');
legend('Original Signal', 'Noise');
grid on;

% Plot 2: Signal-to-Noise Ratio over time
subplot(2,1,2);
signal_power = averaged_signal_data.original_signal.^2;
noise_power = noise.^2;
snr_db = 10*log10(movmean(signal_power, 100) ./ movmean(noise_power, 100));
plot(time, snr_db, 'g', 'LineWidth', 1.5);
title('Signal-to-Noise Ratio (Moving Average)');
xlabel('Time (s)');
ylabel('SNR (dB)');
grid on;
ylim([max(-10, min(snr_db)), max(snr_db)]);  % Reasonable y-axis limits

% Save the figures
savefig('noise_analysis.fig');
saveas(gcf, 'noise_analysis.png');

% Print some statistical information about the noise
fprintf('\n--- Noise Statistics ---\n');
fprintf('Mean: %.6f\n', mean(noise));
fprintf('Standard Deviation: %.6f\n', std(noise));
fprintf('RMS Value: %.6f\n', rms(noise));
fprintf('Peak-to-Peak: %.6f\n', max(noise) - min(noise));
fprintf('Skewness: %.6f\n', skewness(noise));
fprintf('Kurtosis: %.6f\n', kurtosis(noise));
fprintf('Signal-to-Noise Ratio: %.2f dB\n', 10*log10(var(averaged_signal_data.original_signal)/var(noise))); 