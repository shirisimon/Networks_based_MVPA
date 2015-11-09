
function [gradPerformance,p] = MVPAfromICsFunc(subject, runs, nodesNames, VOIName, params, DIM)
% takes RTCs from specific VOIs
% (generally defined in linear correlation to seed region)
% and relvant time points of conditions
% from each condition performanceorme SVM

%-------------------------------------------------------------------------%
% sanity checks - in 2 tmp between allRes L vs R
%-------------------------------------------------------------------------%

prs = cd ;

%% 1. define varibls :
study = 1 ;
%subject = 101 ;
%runs = 1 ;
testname = params.testname ;
filesource = 'mat' ;     % 'bv' - saved manually directly from brain voyager
                         % 'mat' - saved automatically with 'ExRTCsfromVOIs.m'
RT = 0 ;                 % take reaction times time points
SL2meanTmp = 1 ;
% analysis = 'between' ; % 'within' - within run (and than average
                         %  classifiaction performanceormance across runs)
                         % 'between' - between runs (join z-scored runs
                         %  and than compute performanceormance

rtcDir = ['F:\study 1\data\' num2str(subject)] ;
tmpDir = 'F:\study 1\data\' ;
%nodesNames = {'rmc_seed'} ;

%% Networks (in TAL)
% Amg network -   'lAmg_seed', 'lPHG_HT', 'rPHG_HT' , 'rSTP', 'rIFG', 'rfrontPol', 'rCaudate', 'rsCaudate'
% motor network - 'rmc_seed', 'lMFG', 'liMFG', 'rMFG', 'riMFG', 'aMFG', 'mMFG', 'rCC', 'rP', 'lP'

tmp = params.tmp ;
itNum = 100 ;

cd(tmpDir)
load('allsubTMPs.mat', [ 'sub' num2str(subject) ]) ;

matR = [] ;
matL = [] ;
performance = [] ;
shuff = [] ;
performanceVec = [] ;
shuffVec = [] ;

countTmp = 1 ;
for it = 1 : itNum
    for run = runs
        rtcRunDir = [ rtcDir '\run ' num2str(run) '\Network RTCs\' ...
            num2str(subject) '_' VOIName '/' DIM] ;
        cd(rtcRunDir)
        
        %% 2. get RTCs :
        rtcMat = [] ;
        for node = 1 : length(nodesNames)
            switch filesource
                case 'bv'
                    rtc = BVQXfile([ nodesNames{node} '_run' num2str(run) '.rtc']) ;
                    rtc = zscore(rtc.RTCMatrix) ;
                case 'mat'
                    load([ nodesNames{node} '_rtc.mat']) ;
                    rtc = nodeRTC' ;
            end
            rtcMat = [rtcMat , rtc] ;
        end
        
        
        %% 3. get tmps :
        cd(tmpDir)
        if RT == 1
            eval([ 'alltmps = sub' num2str(subject) '.run(' num2str(run)...
                ').tmps_RTs_vol ; ']) ;
        else
            eval([ 'alltmps = sub' num2str(subject) '.run(' num2str(run)...
                ').tmps_vol ; ']) ;
        end
        cd('F:\study 1\analysis\Network SVM');
        
        if strcmp('allTrl',testname) ;
            [~,~,ttmps, btmps] = setTRs(testname, alltmps)  ;
            rtmps = btmps ;
            ltmps = ttmps ;
            
        else
            if RT == 1
                [ltmps, rtmps] = setTRs_RTs(testname, alltmps)  ;
            else
                [ltmps, rtmps] = setTRs(testname, alltmps)  ;
            end
            rtmps = rtmps + tmp ;
            ltmps = ltmps + tmp ;
        end
        
        %     switch analysis
        %         case 'within'
        %             matR = rtcMat(rtmps,:) ;
        %             matL = rtcMat(ltmps,:) ;
        %             [cmbn, xcond] = setCmbn_SL(matL(:,1), matR(:,1)) ;
        %             [dataR, dataL, cmbn] = setCondVols(matR, matL, xcond, cmbn, fac) ;
        %             [dataR, dataL] = factorize(dataR, dataL, size(dataR,1), fac) ;
        %             [performance(run), shuff] = netClassifer(dataR, dataL) ;
        %         case 'between'
        matR = [matR ; rtcMat(rtmps,:)] ;
        matL = [matL ; rtcMat(ltmps,:)] ;
        %     end
    end
       
    %% 4. set factor according to number of trails :
    fac = setfacor(size(matR,1), size(matL,1), size(nodesNames,1)) ;
    
    %% 5. join tmps from all runs :
    %     switch analysis
    %         case 'between'
    if SL2meanTmp == 1 && countTmp == 1 ;
        [cmbn, xcond] = setCmbn_SL(matL(:,1), matR(:,1)) ;
        [dataR, dataL, cmbn] = setCondVols(matR, matL, xcond, cmbn, fac) ;
    else
        [dataR, dataL] = setCondVols(matR, matL, xcond, cmbn, fac) ;
    end
    [dataR, dataL] = factorize(dataR, dataL, size(dataR,1), fac) ;
    trlsNum = size(dataR,1) ;
    [performance, shuff] = netClassifer(dataR, dataL) ;
    performanceVec(it) = performance ;
    shuffVec(it) = shuff ;
    
    
    %         case 'within'
    %             trlsNum = size(dataR,1) ;
    %             performance = mean(performance) ;
    %             performanceVec(it) = performance ;
    %             shuffVec(it) = shuff ;
    %             % performance_shuf = mean(performance_shuf)
    %     end
    matR = [] ;
    matL = [] ;
    performace = [] ;
    shuff = [] ;
    if it ~= itNum
        clear dataL dataR
        clear cmbn
    end
    
end

gradPerformance = mean(performanceVec) ; 
[~,p] = ttest2(performanceVec,shuffVec) ;

cd(prs)
%% 5. save the data
% fileName = [ 's' num2str(subject) '_NetData_' testname '_' ...
%     num2str(tmp) 'tmp_fac' num2str(fac) '.mat' ] ;
% save ( fileName, 'nodesNameVec', 'meanPerformance',...
%     'performanceVec', 'trlsNum', 'itNum', 'analysis')  ;


%-------------------------------------------------------------------------%
%% 6. plot something :
% if size(nodesNames,2) == 3
%     scatter3(dataL(:,1), dataL(:,2), dataL(:,3), 'filled')
%     hold on
%     scatter3(dataR(:,1), dataR(:,2), dataR(:,3), 'filled')
% elseif size(nodesNames,2) == 2
%     scatter(dataL(:,1), dataL(:,2), 'filled')
%     hold on
%     scatter(dataR(:,1), dataR(:,2), 'filled')
% else
% end
%-------------------------------------------------------------------------%

