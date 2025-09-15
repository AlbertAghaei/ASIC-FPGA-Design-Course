clc;
clear;
close all;

%% Read FFT output from files (from Verilog)
FFTI = load('fft_real_out.txt');
FFTQ = load('fft_imag_out.txt');

% Form complex FFT output
FFT_out = FFTI + 1i * FFTQ;

%% Plot magnitude of FFT output as requested
figure;
plot(abs(FFT_out), '-o','LineWidth',1.5);
grid on;
xlabel('Frequency bin');
ylabel('|FFT| Magnitude');
title('FFT Magnitude Spectrum (From Verilog Output)');
