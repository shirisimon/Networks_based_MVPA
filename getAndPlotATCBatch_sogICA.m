%% getAndPlotATCBatch
% get Avg Time Course to each condition from ICs.
clear all; close all; clc

rootdir = 'D:\study 6 - ICs based classification\';
subjects = {'DM' 'EK' 'EL' 'HS' 'IN'}; % {'DM' 'EK' 'EL' 'HS' 'IN' 'LG' 'MK' 'MW' 'TL' 'YR'};
conditions2classify = {'beep','blank'};
tmpFromOnset = [2, 0]; % [tmp of 1st cond, tmp for 2nd cond]
file.output_path = rootdir;
file.output_name = 'ATCs.mat';
runNum = 4;

ics = [1,3:10]; % BOLD ics (unspect by eye and finger print)
trialLimits = 1: 8;
run = struct;
dataA = [];
dataB = [];
for s = 5:size(subjects,2);
    epochsA = 0;
    epochsB = 0;
    %% 1. load task data:
    disp(['Processing subject ' subjects{s}  ': extracting IC time courses']);
    % vtc1 = BVQXfile([path subjects{s} '_bd1_MIA_SCCAI2_3DMCTS_THPGLMF2c_TAL.vtc']); % load task vtc
    vtc1 = findFilesBVQX([rootdir 'data\' subjects{s} '\bd1\'],'*bd1*_TAL.vtc',struct('maxdepth',1) );
    vtc2 = findFilesBVQX([rootdir 'data\' subjects{s} '\bd2\'],'*bd2*_TAL.vtc',struct('maxdepth',1) );
    
    vtc1 = BVQXfile(vtc1{1});
    vtc2 = BVQXfile(vtc2{1});
    vtc1 = zscore(vtc1.VTCData);
    % vtc2 = zscore(vtc2.VTCData);
    vtc = vtc1;
    
    %% 2. Extract rest ICs time courses:
    count = 1;
    for c = ics+(s-1)*27;  % 1:size(ics,2)
        try
            ict(:,count) = extractICTimeCourseFromICMapAndVTC(c, rootdir, vtc, subjects{s}, 1, 0);
            %ict(:,count+1) = extractICTimeCourseFromICMapAndVTC(c, rootdir, vtc, subjects{s}, 1, 1);
            disp(['Extract IC No ' num2str(c) ' for Subject ' subjects{s}]);
        catch err;
        end
        count = count+1;
    end
    
    %% 3. Extract task conditions time points :
    disp(['Processing subject ' subjects{s}  ': extracting condition time points']);
    prt = BVQXfile([rootdir 'data\beep_protocol.prt']); 
    prt = prt.Cond;
    [idxA, idxB] = getConditionsReleventTimePoints...
        (size(vtc1,1), prt, conditions2classify, tmpFromOnset);
    if ~isequal(length(idxA),length(idxB))
        min_trlnum = min(length(idxA),length(idxB));
        idxA = idxA(1:min_trlnum);
        idxB = idxB(1:min_trlnum);
    end
        
    %% 4. plot ATCs:
    hc = 1; % figure handle count
    for ic = 1:size(ict,2);
        h(hc) = figure; 
        for t = 1:size(idxB,1)
            stc(t,:,ic) = ict(idxB(t)+trialLimits(1):idxB(t)+trialLimits(end),ic);
            hold on; plot(trialLimits, ...
                ict(idxB(t)+trialLimits(1):idxB(t)+trialLimits(end),ic), 'blue');    
        end
        atc = mean(stc(:,:,ic));
        hold on; plot(trialLimits, atc, 'black', 'LineWidth',3);
        hc = hc+1;
    end
    
end