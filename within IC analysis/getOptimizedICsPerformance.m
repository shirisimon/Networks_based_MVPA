
%% getOptimizedNetworksPerformance
% This script checks for a seed's Network the best combination of nodes
% from all subjects

% one should make sure all nodes in all subjects have the exact same name 

clear all
%% set parameters :
DIM = 'IC10' ;
params.tmp = 0 ;
params.testname = 'forced' ; 

study = 1 ;
% allSub = struct('subject', {101 105 108 109 112 113 114}, ...
%                 'run', {[1:2] [2 5] [1:4] [1:4] [1:4] [1:4] [1:4]}) ;
allSub = struct('subject', {112}, ...
                'run', {[1:4]}) ;
% allSub = struct('subject',{101 105 108 109 112 113 114},...
%                 'run', {[1:2], [2,5], [1:4], [1:4], [1:4]) ; 

% icNames = {'IC10', 'IC21', 'IC29'} ;
icNames = {'FPC_IC10', 'lPFC_IC10', 'rPFC_IC10', 'rPreC_IC10', 'lPreC_IC10',...
    'PCC_IC10', 'pre-SMA_IC10'};
    
% icNames = {'ACC_IC29', 'lDLPFC_IC29', 'rDLPFC_IC29', 'LMC_IC29', ...
%   'RMC_IC29', 'SMA_IC29', 'pre-SMA_IC29'} ;
VOIName = 'restICs' ;


maxPerformance = 0 ;
combination = 0 ;
cNum = 0 ;
allSubPerformance = [] ;
allSubPval = [] ;

% compute number of combinations :
for k = 1 : size(icNames,2) ;
    ckNum = nchoosek(size(icNames,2),k) ;
    cNum = cNum + ckNum ;
end

for k = 1 : size(icNames, 2)    % num of region in the network
    c = nchoosek(icNames, k) ;
    for i = 1 : size(c,1)
        combination = combination +1 ;
        disp(['progress : ' num2str((combination/cNum)*100) '%'])
        icName = c(i,:) ;
        icNumsTable{combination} = icName ;
        subNum = 0 ;
        for subject = allSub ;
            subNum = subNum + 1 ;
            [Performance,p] = MVPAfromICsFunc(subject.subject, ...
                subject.run, icName, VOIName, params, DIM) ;
            allSubPerformance = [ allSubPerformance Performance ] ;
            % allSubPval = [allSubPval p] ;
        end
        allSubPerformanceTable(combination,:) = allSubPerformance ; %% check
        % allSubPvalTable(combination,:) = allSubPval ;
        
        meanSubPerformance = mean(allSubPerformance) ;
        % meanSubPval = mean(allSubPval);
        
        if maxPerformance <= meanSubPerformance
            maxNodesCombinPerformace = icName ;
            maxAllSubPerformance = allSubPerformance ; %% check
            % maxAllSubPval = allSubPval ;
        end
        maxMeanPerformance = max([maxPerformance meanSubPerformance]) ; %% check
        allSubPerformance = [] ;
    end
end
% allSubPerformanceTable(:,8) = mean(allSubPerformanceTable,2) ;
% save('LMCseed_allSubPerformance', 'allSubPerformanceTable', 'nodesNameTable') ;
allSubPerformanceTable
% allSubPvalTable
max(allSubPerformanceTable)
% max(allSubPval)