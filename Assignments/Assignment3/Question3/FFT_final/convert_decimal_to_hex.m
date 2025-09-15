% Read decimal data from files (comma-separated)
I_data = readmatrix('I.txt', 'Delimiter', ',');
Q_data = readmatrix('Q.txt', 'Delimiter', ',');

% Open output files for writing hexadecimal values
fid_I = fopen('I_hex.txt', 'w');
fid_Q = fopen('Q_hex.txt', 'w');

% Convert and write I data to hex
for k = 1:length(I_data)
    if I_data(k) < 0
        fprintf(fid_I, '%04X\n', typecast(int16(I_data(k)), 'uint16'));
    else
        fprintf(fid_I, '%04X\n', I_data(k));
    end
end

% Convert and write Q data to hex
for k = 1:length(Q_data)
    if Q_data(k) < 0
        fprintf(fid_Q, '%04X\n', typecast(int16(Q_data(k)), 'uint16'));
    else
        fprintf(fid_Q, '%04X\n', Q_data(k));
    end
end

% Close files
fclose(fid_I);
fclose(fid_Q);
