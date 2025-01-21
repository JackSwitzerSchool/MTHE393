plot(omega.time, omega.signals.values)
hold on
plot(theta.time, theta.signals.values)
hold off

% title('Angular Position and Angular Velocity of the Motor over Time for Epsilon = 10')
title('Impulse Response of Omega and Theta Over Time Using a Pulse Generator for Epsilon = 1')
xlabel('Time (s)')
ylabel('Angular Position (rad) and Angular Velocity (rad/s)')
legend('theta','omega')