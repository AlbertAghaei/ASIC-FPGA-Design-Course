% Open the file
filename = 'fft_output.txt';
fid = fopen(filename, 'r');

if fid == -1
    error('Unable to open file %s', filename);
end

% Read the data
fft_data = [];

% Read each line and convert it to hex value
while ~feof(fid)
    line = fgetl(fid);
    
    if startsWith(line, '0x')  % Process only lines that start with '0x' (hex number)
        hex_value = sscanf(line, '%x');  % Read the hex value
        fft_data = [fft_data; hex_value];  % Append to the array
    end
end

fclose(fid);

% Display the data
disp('FFT Data:');
disp(fft_data);

% Plot the FFT output (if needed)
figure;
stem(fft_data);
title('FFT Output Data');
xlabel('Index');
ylabel('Magnitude');
