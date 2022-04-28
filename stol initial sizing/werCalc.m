clear; clc; close;

cwd = pwd;

cd ..
cd ..

catData = readmatrix('Catalogue - Data.xlsx');

AR = catData(:, 8) .^ 2 ./ catData(:, 9);
W0 = catData
P_W = catData(:, 15) ./ catData(:, 11);
W


