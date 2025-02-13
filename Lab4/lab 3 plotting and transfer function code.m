plot(input.time, input.Data)
hold on
plot(output.time, output.Data)
hold off

% title('Angular Position and Angular Velocity of the Motor over Time for Epsilon = 10')
title('Input vs Output Plot Over Time: u(t) = sin(t)')
xlabel('Time (s)')
ylabel('Output Magnitude')
legend('input','output')


%For creating system, getting transfer function, and getting impulse
%response: VVV
%A = [], B = [], C = ...
%sys = ss(A,B,C,D)
%t = tf(sys)
%impulse(t)