% diagnostics_main
clear all; close all; clc

dataset = load('data.mat');
dataset = dataset.data;
train_size = round(size(dataset,1)*0.7);
train_set = dataset(1:train_size,:);
cv_set = dataset(train_size+1:end,:);

c_power = 14; % 14:20; % C = 1 - lambda parameters to test
g_power = 1; % 1:5; % gamma - size of sigma^2 in RBF kernel

% check defult params results withot scaling:
model = svmtrain(train_set(:,1), train_set(:,2:end));
[~,acc] = svmpredict(cv_set(:,1), cv_set(:,2:end), model);
disp(['accuracy without scaling: ', num2str(acc(1))]);

% check defult params results with scaling between [0,1]:
dataset(:,2:end) = mapminmax(dataset(:,2:end),0,1);
train_set = dataset(1:train_size,:);
cv_set = dataset(train_size+1:end,:);
model = svmtrain(train_set(:,1), train_set(:,2:end));
[~,acc] = svmpredict(cv_set(:,1), cv_set(:,2:end), model);
disp(['accuracy with scaling [0,1]: ', num2str(acc(1))]); 

% params with scaling: 
for c = 1:length(c_power)
    for g = 1:length(g_power) 
        svmcost = 2^c_power(c);
        gamma = 2^g_power(g);
        model = svmtrain(train_set(:,1), train_set(:,2:end), ...
            ['-c ', num2str(svmcost), ' -g ', num2str(gamma)]);
        [~,acc] = svmpredict(cv_set(:,1), cv_set(:,2:end), model);
        accuracy(c,g) = acc(1);
    end
end

figure;
subplot(2,1,1); plot(c_power, accuracy(:,1)); title('C');
subplot(2,1,2); plot(g_power, accuracy(1,:)); title('gamma');

disp(['accuracy with best c and gamma: ', num2str(acc(1))]); 


