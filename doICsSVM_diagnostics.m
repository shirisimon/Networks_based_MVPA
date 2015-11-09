function [C, gamma, acc] = doICsSVM_diagnostics(dataA, dataB, params)

factor = params.factor;
%% feature normalization 
norm_data = zscore([dataA; dataB]);
dataA = norm_data(1:45,:);
dataB = norm_data(46:end,:);

%% data preperation: 
train_size = round(size(dataA,1)*0.6);
dataA_train = dataA(1:train_size,:);
dataA_val = dataA(train_size+1:end,:);
dataB_train = dataB(1:train_size,:);
dataB_val = dataB(train_size+1:end,:);

labels_train = ([ones(size(dataA_train,1)/factor , 1); ...
    ones(size(dataB_train, 1)/factor, 1)*(-1)]);
labels_val = ([ones(size(dataA_val,1)/factor, 1); ...
    ones(size(dataB_val, 1)/factor, 1)*(-1)]);


c_power = -5:15; % 14:20; % C - 1/lambda (regularization)
g_power = -5:15; % 1:5; % gamma - size of sigma^2 in RBF kernel
for c = 1:length(c_power)
    cost = 2^c_power(c);
    for g = 1:length(g_power) 
        gamma = 2^g_power(g);
        model = svmtrain(labels_train, [dataA_train; dataB_train], ...
            ['-t 0', ' -c ', num2str(cost), ' -g ', num2str(gamma)]);
        [~,acc] = svmpredict(labels_val, [dataA_val; dataB_val], model);
        accuracy(c,g) = acc(1);
    end
end
[c_idx, g_idx] = find(accuracy == max(accuracy(:)));
C = 2^c_power(c_idx(1));
gamma = 2^g_power(g_idx(1));
acc = max(max(accuracy));

%figure;
%subplot(2,1,1); plot(c_power, accuracy(:,1)); title('C');
%subplot(2,1,2); plot(g_power, accuracy(1,:)); title('gamma');
end