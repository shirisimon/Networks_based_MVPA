function acc = doICsSVM(dataA, dataB, params, file, doShuffle)
% Exustive permutation is default since we always have <=30 dimentions

if doShuffle
    mapsNum = 100; %% shuffle maps num
else
    mapsNum = 1;
end
factor  = params.factor;
permNum = size(dataA,1)*size(dataB,1);
allAccs = zeros(permNum,1);
accForMultiMaps = allAccs;

%% feature noramlization:
% dataA = mapminmax(dataA,0,1);
% dataB = mapminmax(dataB,0,1);
norm_data = zscore([dataA; dataB]);
dataA = norm_data(1:45,:);
dataB = norm_data(46:end,:);

%% 1. Generate labels
for m = 1:mapsNum; % number of maps (>1 for shuffled labels)
        labels = ([ones(size(dataA,1)/factor - 1, 1); ...
            ones(size(dataB, 1)/factor - 1, 1)*(-1)]); % SHUFFLE LABELS
    if doShuffle
        p = randperm((size(dataA,1)/factor)*2-2);
        labels(:,m) = labels(p);
        disp(['Shuffle Progress :' num2str(m) '/' num2str(mapsNum) ]);
    end

    idx = 1:size(dataA);
    p = 0;
    for pa = 1:size(dataA,1);
        for pb = 1:size(dataA,1)
            perm1 = idx([pa, 1:pa-1, pa+1:end]);
            perm2 = idx([pb, 1:pb-1, pb+1:end]);
            dataA_perm = dataA(perm1,:);
            dataB_perm = dataB(perm2,:);
            p = p+1;
            allAccs(p,:) = doSVM...
                (dataA_perm, dataB_perm, params.factor, labels(:,m), params);
        end
    end
    acc1Map = mean(allAccs);
    accForMultiMaps(1,m) = acc1Map;
end

if doShuffle
    acc_shuffledLabels = accForMultiMaps(1,:); 
    save([file.output_path file.output_name],'acc_shuffledLabels', 'labels','-append');
    acc = acc_shuffledLabels;
else
    acc_realLabels = acc1Map;
    allPermutationAcc_realLabels = allAccs;
    save([file.output_path file.output_name],'allPermutationAcc_realLabels', ...
        'acc_realLabels', '-append');
    acc = acc_realLabels;
end
end


function acc = doSVM(dataA, dataG, factor, labels, params)
dataA  = double(dataA);
dataG  = double(dataG);
regionSize = size(dataA,2);

trainA = zeros(size(dataA,1)/factor-1, size(dataA,2));
trainG = zeros(size(dataG,1)/factor-1, size(dataG,2));
testA = zeros(1, regionSize);
testG = zeros(1, regionSize);

perm1 = ceil(1:size(dataA, 1)/factor) ;
perm2 = ceil(1:size(dataA, 1)/factor) ;
if factor > 1
    testA = mean(dataA(find(perm1==1),:));
    testG = mean(dataG(find(perm2==1),:));
else
    testA = dataA(1,:);
    testG = dataG(1,:);
end
for k=1:size(trainA,1)
    if factor > 1
        trainA(k,:) = mean(dataA(find(perm1==k+1),:));
        trainG(k,:) = mean(dataG(find(perm2==k+1),:));
    else
        trainA(k,:) = dataA(find(perm1==k+1),:);
        trainG(k,:) = dataG(find(perm2==k+1),:);
    end
end

trainNoShuffle = [trainA; trainG];
train = trainNoShuffle;%(perm,:);
test = [testA; testG];
predicted = [1;-1];
model = svmtrain(labels, train, ...
    ['-t 0', '-c ', num2str(params.c), ' -g ', num2str(params.g)]);
[~, accuarcy] = svmpredict(predicted, test, model);
acc = accuarcy(1)/100;
end