plot(omega.time,theta.signals.values)
title('Angular Position of the Motor over Time')
xlabel('Time (s)')
ylabel('Angular Position (rad)')
hold off
plot(theta.time,omega.signals.values)
title('Angular Velocity of the Motor')
xlabel('Time (s)')
ylabel('Angular Velocity (rad/sec)')
