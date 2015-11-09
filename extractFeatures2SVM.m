
function [dataA, dataB,  sorted_features] = extractFeatures2SVM(dataA_orig, dataB_orig, ...
    sorted_features, params)
while size(dataA_orig,2)>1
    for f = 1:size(dataA_orig,2)
        dataA = dataA_orig(:, setdiff(1:size(dataA_orig,2), f));
        dataB = dataB_orig(:, setdiff(1:size(dataB_orig,2), f));
        [params.c, params.g, acc(f)] = doICsSVM_diagnostics(dataA, dataB, params);
    end
     feature2extract = find(acc == max(acc));
     disp(['Using ' num2str(size(dataA_orig,2)-1) ...
           ' features, best accuracy is: ' num2str(max(acc)) ])
     dataA = dataA_orig(:, setdiff(1:size(dataA_orig,2), feature2extract));
     dataB = dataB_orig(:, setdiff(1:size(dataB_orig,2), feature2extract));
     sorted_features = [sorted_features feature2extract];  % reverse order 
     [dataA, dataB,  sorted_features] = ...
         extractFeatures2SVM(dataA, dataB, sorted_features, params);
end
end