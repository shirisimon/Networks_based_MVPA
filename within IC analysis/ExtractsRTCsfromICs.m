

%% ExtractsRTCsfromICs
% after tun ICA, peak relevant components and save nodes as VOI with 
% with the extansion - [ node Name '_IC' ICNum]

clear all
prs = pwd ;

%% 1. define varibls
study = 1 ;
allSub = struct('subject',{112},...
                'run', { [1:4] }) ;

%% Extract VOI
VOIPath = ['F:/study ' num2str(study) '/data/112/VOIs'] ;
cd(VOIPath);
VOI = BVQXfile('112_ICArest.voi') ;            

tic
subNum = 0 ;
for subject = allSub ;
    subNum = subNum + 1 ;
    for run = 1:4 ;
        
        %% 3. Extract VTCs
        % for each vtc
        VTCPath = ['F:/study ' num2str(study) '/data/' ...
            num2str(subject.subject) '/run ' num2str(run) '/' ] ;
        cd(VTCPath)
        switch run
            case {1,2,3,4}
                VTCName = [num2str(subject.subject) '_run' num2str(run)...
                    '_SCCAI_3DMCTS_THPGLMF2c_TAL.vtc'] ;
            case {5,6,7,8}
                VTCName = [num2str(subject.subject) '_run' num2str(run-4)...
                    '_SCCAI_3DMCTS_THPGLMF2c_TAL_avgFix.vtc'] ;
        end
            
        VTC = BVQXfile(VTCName) ;
        
        %% 4. Extract VOIs time course
        voiData = VTC.VOITimeCourse(VOI, inf) ;           % load voi's vtc
        for node = 1 : length(VOI.VOI)                    % for each node in voi file
            % nodeData = unique(voiData{node}', 'rows') ; % erase identical voxels RTC
            nodeData = voiData{node}' ;
            
            %% 5. create RTC - mean all voxels vector
            nodeRTC = zscore(mean(nodeData)) ;
            %% 6. save RTC
            RTCName = [VOI.VOI(node).Name '_rtc.mat'] ;
            % RTCPath = regexpi(VTCName, '.*\/', 'match') ;
            % cd(RTCPath{1})
            
            
            cd(VTCPath)
            if exist('Network RTCs', 'dir') == 0
                mkdir('Network RTCs')
            end
            cd([VTCPath '/Network RTCs'])
            if exist('112_restICs', 'dir') == 0
                mkdir('112_restICs')
            end
            cd([VTCPath '/Network RTCs/112_restICs'])
           
            save(RTCName, 'nodeRTC') ;
            cd(VOIPath)
            
        end
        % VOI.ClearObject ; clear VOI ; clear ans
        VTC.ClearObject ; clear VTC ; clear ans
        
        
    end
end


