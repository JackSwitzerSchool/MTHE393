plot(input.time, input.signals.values)
hold on
plot(omega.time, omega.signals.values)
plot(zero.time, zero.signals.values)
hold off

title('Input Signal vs Output (Theta) Signal - Sine Wave Frequency = 300')
%title('Impulse Response of Omega and Theta Over Time Using a Pulse Generator for Epsilon = 1')
xlabel('Time (s)')
ylabel('Amplitude')
legend('Input','Omega')


%bode from a transfer function
%t = 0.028
%h = tf([0 250],[1 1/t])
%bode(h)