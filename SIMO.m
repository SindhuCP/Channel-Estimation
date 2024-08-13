%SIMO

clc;
N = 10^4; % 10,000 more N better ber
SNRdB = 0:2:40; % Range of SNR values in dB
BER = zeros(1, length(SNRdB)); % Initialize BER array

for i = 1:length(SNRdB)
    snrdb = SNRdB(i);
    snrlin = db2pow(snrdb); %lin scale
    
    % Generate random bits
    x = randi([0 1], 1, 2*N); % seq of 20,000 bits of 0s and 1s
    
    % QPSK Modulation (Baseband)
    xmod = ((1-2*x(1:2:end)) + 1j * (1-2*x(2:2:end))) / sqrt(2);
    
    % Channel: Assume two independent channels (SIMO)
    h1 = (randn(1, N) + 1j * randn(1, N)) / sqrt(2);
    h2 = (randn(1, N) + 1j * randn(1, N)) / sqrt(2);
    
    % Noise generation
    noise1 = (randn(1, N) + 1j * randn(1, N)) / sqrt(2);
    noise2 = (randn(1, N) + 1j * randn(1, N)) / sqrt(2);
    
    % Received signal with noise through the channels
    yrx1 = h1 .* xmod + sqrt(1/snrlin) * noise1;
    yrx2 = h2 .* xmod + sqrt(1/snrlin) * noise2;
    
    % Combine the received signals using Maximum Ratio Combining (MRC)
    yrx_combined = (conj(h1) .* yrx1 + conj(h2) .* yrx2) ./ (abs(h1).^2 + abs(h2).^2);
    % optimally combines the received signals to maximize the signal-to-noise ratio (SNR),
    % thus improving the reliability and performance of the communication system. 
    % This technique is particularly useful in combating the effects of multipath fading and noise.
    
    % QPSK Demodulation
    ydemod = zeros(1, 2*N);
    ydemod(1:2:end) = real(yrx_combined) < 0; % In-phase component
    ydemod(2:2:end) = imag(yrx_combined) < 0; % Quadrature component
    
    % BER Calculation
    BERcount = sum(xor(ydemod, x));
    BER(i) = BERcount / N;
end


% Plot BER vs SNR
figure;
semilogy(SNRdB, BER, '-o');
xlabel('SNR (dB)');
ylabel('BER');
title('BER vs SNR for SIMO QPSK');
grid on;