%% runICsSVMBatch
%% INTERMIDIATE CONC. 1:
% the best results for 'rest' are in 'res_mean_boldICsMan_fineTuned'
% exp: noisy features (components) impair the classification accuracy (e.g.
% using all components or including sogICA yeild worse results)
%% INTERMIDIATE CONC. 2:
% the best results for 'task' (run on vtc1) are in 'res_vtc1_boldICsMan_fineTuned'
% using the same scan for ica and classification is over fitting because
% the results for vtc2 are much worse

%% PARAMS FITTING:
% tmp from onset - 4 is the best
% try concate zscore with factor 2 vtc vs mean vtcs (zscored) - same
% try normalize the component time course - same
% try feature selection with sogICA (same)
% normalized features between [0,1] - very helpful
% fine tunning c and gamma - same

clear all; close all; clc

%% params
res_name                    = 'mean_tmp2_other';
loc_type                    = 'task';

load([loc_type '_bold_ics_man.mat']);

save_results                = 1;
do_shuffle                  = 0;
do_featureSelection         = 0;
featuresNum                 = 10;

rootdir                     = 'D:\study 6 - ICs based classification\';
subjects                    = {'DM'  'EK' 'EL' 'HS' 'IN' 'LG' 'MK' 'MW' 'TL' 'YR'};
classificationName          = 'beep'; % run on free, forced
conditions2classify         = {'beep','blank'};
tmpFromOnset                = [2, 0]; % [tmp of 1st cond, tmp for 2nd cond]
ics                         = 1:27;

params.ica.inverse_polarity = 0;
params.ica.sogica           = 0;
params.shuffleMapsNum       = 100; %% shuffle maps num
params.factor               = 1;


for s = 1:size(subjects,2); % iteretae over subjects
    file.output_path = [rootdir 'results\'];
    file.output_name = ...
        [subjects{s} '_MCPA_' classificationName num2str(tmpFromOnset(1)) '.mat'];
    
    %% 1. load task data:
    disp(['Processing subject ' subjects{s}  ': extracting IC time courses']);
    % vtc1 = BVQXfile([path subjects{s} '_bd1_MIA_SCCAI2_3DMCTS_THPGLMF2c_TAL.vtc']); % load task vtc
    vtc1 = findFilesBVQX([rootdir 'data\' subjects{s} '\bd1\'], ...
        '*bd1*_TAL.vtc',struct('maxdepth',1) );
    vtc2 = findFilesBVQX([rootdir 'data\' subjects{s} '\bd2\'], ...
        '*bd2*_TAL.vtc',struct('maxdepth',1) );
    
    vtc1 = BVQXfile(vtc1{1});
    vtc2 = BVQXfile(vtc2{1});
    vtc1 = zscore(vtc1.VTCData);
    vtc2 = zscore(vtc2.VTCData);
    vtc = vtc2;
    % vtc =  (vtc1 + vtc2)/2; % mean
    % vtc = [vtc1; vtc2]; % concatinate
    
    
    %% 2. Extract rest ICs time courses:
    for c = ics ; % 'c = ics' (for 1:27 cmps) OR 'c = bold_ics_man{s,2}'
        %try
        if strcmp(loc_type, 'rest')
            ict(:,c) = extractRestICATimeCourseFromICMapAndVTC...
                (c, rootdir, vtc, subjects{s}, params);
        else
            ict(:,c) = extractTaskICATimeCourseFromICMapAndVTC...
                (c, rootdir, vtc, subjects{s}, params);
        end
        disp(['Extract IC No ' num2str(c) ' for Subject ' subjects{s}]);
        %catch err;
        %end
    end
    
    %% 3. Extract task conditions time points :
    disp(['Processing subject ' subjects{s}  ': extracting condition time points']);
    prt = BVQXfile([rootdir 'data\beep_protocol.prt']);
    prt = prt.Cond;
    [idxA, idxB] = getConditionsReleventTimePoints...
        (size(vtc1,1), prt, conditions2classify, tmpFromOnset);
    
    %% 4. Assign ICs weights to task relevant volumes
    if size(vtc,1) > size(vtc1,1) % if vtc is concatinated
        idxA = [idxA; idxA+size(vtc1,1)];
        idxB = [idxB; idxB+size(vtc1,1)];
    end
    dataA = ict(idxA,:);
    dataB = ict(idxB,:);
    
    %% 4. Extract equal number of trials from all conditions :
    [dataA_orig, dataB_orig, trials] = getConditionsEqualNumOfPoints(dataA, dataB);
    save([file.output_path file.output_name], 'dataA', 'dataB', 'params');
    
    %% 5. doMCPA
    load(fullfile(file.output_path, file.output_name));   
    
    %%% TODO %%% : insert to recursive function
    if do_featureSelection
        disp(['Processing subject ' subjects{s} ': selecting SVM features'])
        [~, ~,  sorted_features(:,s)] = ...
            extractFeatures2SVM(dataA_orig, dataB_orig, [], params);
        dataA = dataA_orig(:,sorted_features(end-featuresNum:end));
        dataB = dataB_orig(:,sorted_features(end-featuresNum:end));
    else
        dataA = dataA_orig;
        dataB = dataB_orig;
        sorted_features = [];
    end
    
     % fine-tuning SVM params:
    disp(['Processung subject ' subjects{s} ': running SVM diagnostics'])
    [params.c, params.g] = doICsSVM_diagnostics(dataA, dataB, params);
    params.svm_params.cost(s) = params.c;
    params.svm_params.gamma(s) = params.g;
    
    % real :
    realAcc = doICsSVM(dataA, dataB, params, file, 0);
    fprintf('real accurcy with %d features for subject %s : %.4f \n',  ...
        featuresNum, subjects{s}, realAcc);
    res{s,1} = subjects{s};
    res{s,2} = realAcc;
    
    % shuffle :
    if do_shuffle
        shuffleAccDist = doICsSVM(dataA, dataB, params, file, 1);
        fprintf('highest shuffle accuracy : %.4f \n', max(shuffleAccDist));
        % get p value :
        sortShuffleDist = sort(shuffleAccDist);
        logSort = realAcc > sortShuffleDist;
        pval = 1 - sum(logSort)/length(logSort);
        fprintf('p value (FWER) : %.4f \n', max(pval));
        res{s,3} = {shuffleAccDist};
        res{s,4} = pval;
    end
    
    
    %% cleanup memory
    root=BVQXfile();
    root.ClearObjects('prt');
    root.ClearObjects('vtc');
    root.ClearObjects('ica');
    clear ict
    clear dataA dataA_orig idxA
    clear dataA dataA_orig idxB
    
end
res_vars = {'subject_name', 'real_acc', 'shuffle_acc_dist', 'pval'};
eval(['res_' res_name ' = res;']);
if save_results
    save([loc_type '_results_v2.mat'], 'res_vars', ['res_' res_name], '-append');
end
disp('DONE!')
beep


%% parameters fitting
% tmp from onset - 2 is better than 3
% try concate zscore with factor 2 vtc vs mean vtcs (zscored)
% try normalize the component time course
% try svm linear and RBF kernels and params fitting (with diagnostics)

% try pca or reduction of ICs with high variance time averaged time course

% try with task
% 






