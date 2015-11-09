function [dataA, dataB, trials] = getConditionsEqualNumOfPoints(dataA, dataB)

trials.sizes = [size(dataA,1), size(dataB,1)]; 
    if size(dataA,1) > size(dataB,1) % 1 - if A > B, 0 - if B > A
%         inds = randperm(size(dataA,1));
%         trails.indsFromLargerDataset = inds(1:size(dataB,1));
%         dataA = dataA(trails.indsFromLargerDataset,:);
          dataA = dataA(1:size(dataB,1),:);
    elseif size(dataA,1) < size(dataB,1)
%         inds = randperm(size(dataB,1));
%         trails.indsFromLargerDataset = inds(1:size(dataA,1));
%         dataB = dataB(trails.indsFromLargerDataset,:);
          dataB= dataB(1:size(dataA,1),:);
    end
    
end