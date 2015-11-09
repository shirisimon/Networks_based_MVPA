
%% ExtractAllNetRTCfromIC 

clear all
prs = pwd ;

%% 1. define varibls
ICNum = '29' ;
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
        cd([VTCPath '/Network RTCs/112_restICs/IC' ICNum])
        matfiles = what ;
        matfiles = matfiles.mat ;
        
        %% 4. Extract VOIs time course
        for node = 1 : length(matfiles)                    % for each node in voi file
            % nodeData = unique(voiData{node}', 'rows') ;  % erase identical voxels RTC
            load(matfiles{node}) 
            ICRTC(node,:) = nodeRTC ;   
        end
        
        ICRTC = mean(ICRTC);
   
        
        %% get network averaged RTC
        cd([VTCPath '/Network RTCs/112_restICs/allICs'])
        save(['IC' ICNum '_rtc.mat'], 'ICRTC'); 
        
    end
end



