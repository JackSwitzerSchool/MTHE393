figure;
plot(f1.output.time-4,f1.output.signal)
hold on
plot(f2.output.time,f2.output.signal)
hold off

title('Output of sin(t) shifted by -4 and sin(t-4)')
%title('Impulse Response of Omega and Theta Over Time Using a Pulse Generator for Epsilon = 1')
xlabel('Time (s)')
ylabel('Amplitude')
legend('sin(t) shifted by 4','sin(t-4)')