

%% plotPowerSpectrum
ica = BVQXfile('112_rest_SCCAI_3DMCTS_THPGLMF2c_TAL.ica');
data29 = ica.Map(29).TimePointData;


Fs = 0.5;                     % 2 SEC - 0.5 Hz
T = 1/Fs;                     % Sample time
L = 116;                      % TRs
t = (0:L-1)*T;                % Time vector
y = data29;                   
plot(Fs*t,y)
title('IC10 TimePointData')
xlabel('time (milliseconds)')

%% taken from 'help fft' - dont understand this computations
NFFT = 2^nextpow2(L); % Next power of 2 from length of y        
Y = fft(y,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);

% Plot single-sided amplitude spectrum.
plot(f,2*abs(Y(1:NFFT/2+1)))
title('Amplitude Spectrum of IC29')
xlabel('Frequency (Hz)')
ylabel('Power')       % dont know the units