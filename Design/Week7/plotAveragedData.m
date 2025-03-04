% This script loads and plots the averaged signal data

% Path to the averaged signal data
data_path = 'C:\Users\jacks\Documents\Life\School\3rd Year\W2025\MTHE393\Design\Week7\averaged_signal_data.mat';

% Check if the file exists
if ~exist(data_path, 'file')
    error(['File not found: ' data_path '. Run saveAveragedData.m first.']);
end

% Load the data
load(data_path);

% Create a figure with subplots
figure('Position', [100, 100, 900, 700]);

% Plot original signal
subplot(3,1,1);
plot(averaged_signal_data.time, averaged_signal_data.original_signal, 'b', 'LineWidth', 1.5);
title('Original Signal');
xlabel('Time');
ylabel('Amplitude');
grid on;

% Plot reconstructed signal
subplot(3,1,2);
plot(averaged_signal_data.time, averaged_signal_data.reconstructed_signal, 'g', 'LineWidth', 1.5);
title('Reconstructed Signal (Denoised)');
xlabel('Time');
ylabel('Amplitude');
grid on;

% Plot noise
subplot(3,1,3);
plot(averaged_signal_data.time, averaged_signal_data.noise, 'r', 'LineWidth', 1.5);
title('Noise Component');
xlabel('Time');
ylabel('Amplitude');
grid on;

% Add a main title
sgtitle('Signal Analysis Results');

% Create a second figure for frequency response
figure('Position', [200, 200, 800, 500]);
semilogx(averaged_signal_data.frequencies, averaged_signal_data.magnitudes, 'b-', 'LineWidth', 1.5);
hold on;

% Find the indices of dominant frequencies
[~, peak_indices] = ismember(averaged_signal_data.dominant_frequencies, averaged_signal_data.frequencies);
peak_magnitudes = averaged_signal_data.magnitudes(peak_indices);

% Plot dominant frequencies
semilogx(averaged_signal_data.dominant_frequencies, peak_magnitudes, 'ro', 'MarkerSize', 10);
xlabel('Frequency (rad/s)');
ylabel('Magnitude');
title('Frequency Response with Dominant Frequencies');
grid on;

% Add a legend
legend('Frequency Response', 'Dominant Frequencies');

% Save the figures
savefig('signal_analysis_plots.fig');
saveas(gcf, 'signal_analysis_plots.png'); 