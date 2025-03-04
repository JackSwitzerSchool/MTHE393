% Load the pure noise data
load('pure_noise.mat');  % Contains time_values and pure_noise

% Load one of the original signal files (using file_name13 as reference)
original_data = load('file_name13.mat');
struct_name = fieldnames(original_data);
main_struct = original_data.(struct_name{1});
original_signal = main_struct.output.signal;

% Create figure 1: Overlay plot
figure(1);
plot(time_values, original_signal, 'b', 'LineWidth', 2);
hold on;
plot(time_values, pure_noise, 'r', 'LineWidth', 1.5);
xlabel('Time');
ylabel('Amplitude');
title('Original Signal vs Pure Noise');
legend('Original Signal', 'Pure Noise');
grid on;
savefig('signal_vs_noise_overlay.fig');
saveas(gcf, 'signal_vs_noise_overlay.png');

% Create figure 2: Subplot comparison
figure(2);
subplot(2,1,1);
plot(time_values, original_signal, 'b', 'LineWidth', 2);
xlabel('Time');
ylabel('Amplitude');
title('Original Signal');
grid on;

subplot(2,1,2);
plot(time_values, pure_noise, 'r', 'LineWidth', 2);
xlabel('Time');
ylabel('Amplitude');
title('Pure Noise');
grid on;

% Adjust the layout to prevent overlap
set(gcf, 'Position', [100, 100, 800, 600]);
sgtitle('Signal and Noise Comparison');

% Save the subplot figure
savefig('signal_and_noise_subplots.fig');
saveas(gcf, 'signal_and_noise_subplots.png'); 