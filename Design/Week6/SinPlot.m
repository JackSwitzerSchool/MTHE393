plot(cos.output.time, cosSin.output.signal)
hold on
sin_interp = interp1(sin.output.time, sin.output.signal, cosSin.output.signal, 'linear', 'extrap');
plot(cos2.output.time, (sin_interp + cos.output.signal))
hold off

title('2 x Output of Cos(t) vs Output of 2*Cos(t)')
