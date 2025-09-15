clc; clear; close all;

% Load input signals I,Q
I = load('I.txt');
Q = load('Q.txt');

% MATLAB FFT calculation (16 samples)
FFT_matlab = fft(I + 1i*Q, 16);

% Load FFT results from Verilog (first 16 samples only)
FFTI = load('fft_real_out.txt');
FFTQ = load('fft_imag_out.txt');
FFT_verilog = FFTI(1:16) + 1i*FFTQ(1:16);

% Normalize Verilog output
FFT_verilog_norm = FFT_verilog * max(abs(FFT_matlab))/max(abs(FFT_verilog));

% Plot both results
figure;
subplot(2,1,1);
plot(0:15,abs(FFT_matlab), '-o');
title('FFT Magnitude (MATLAB)');
xlabel('Frequency bin');
ylabel('|FFT|');
grid on;

subplot(2,1,2);
plot(0:15,abs(FFT_verilog_norm), '-o');
title('FFT Magnitude (Verilog Normalized)');
xlabel('Frequency bin');
ylabel('|FFT|');
grid on;

