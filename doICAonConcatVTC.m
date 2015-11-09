function doICAonConcatVTC()
% For each subject concatenate prts and vtcs to 1 run for each subject
% run ICA on each concated VTC
do_prtconcat = 0;

%% 1. Find All Files
rootDir = 'F:\Study 1 - Spontanious Activity Selecction Bias\fMRI\Data';
% define input files patterns:
subjectPattern  = '1*';
vtcFilePattern  = '*run*_SCCAI_3DMCTS_THPGLMF2c_*TAL.vtc';
prtFilePattern  = '*PRT*_decision_vol.prt';
mskFilePattern  = '*GM_TAL.msk'; % gray matter mask
% define input folders and search depth:
subjectFolders  = findfiles(rootDir,subjectPattern,'dirs=1','depth=1');
vtcDepth = '2'; % depth in folders you want to search for VTC files from subject directory
prtDepth = '2'; % depth in folders you want to search for PRT files from subject directory
mskDepth = '2';

for s = 1:length(subjectFolders) % itirate over subjects to find files
    [~,subName]  = fileparts(subjectFolders{s});
    fileNames.(['s' subName]).folder = subjectFolders{s};
    rootDir = fileNames.(['s' subName]).folder;
    vtcFiles = findfiles(rootDir,vtcFilePattern,['depth=' vtcDepth] );
    prtFiles = findfiles(rootDir,prtFilePattern,['depth=' prtDepth]);
    mskFile = findfiles(rootDir,mskFilePattern,['depth=' mskDepth]);
    fileNames.(['s' subName]).mask = mskFile{1};
    for r= 1:length(vtcFiles)
        fileNames.(['s' subName]).(['run' num2str(r)]).vtcFileName = vtcFiles{r};
        fileNames.(['s' subName]).(['run' num2str(r)]).prtFileName = prtFiles{r};
    end
end


for s = 6:length(subjectFolders) % itirate over subjects to find files
    [~,subName]  = fileparts(subjectFolders{s});
    runNum = length(fieldnames(fileNames.(['s' subName])))-2;
    
    %% 2. Concatenate VTCs
    % concat prts:
    if do_prtconcat
        prt1 = BVQXfile(fileNames.(['s' subName]).(['run' num2str(1)]).prtFileName);
        prt2 = BVQXfile(fileNames.(['s' subName]).(['run' num2str(2)]).prtFileName);
        newprt = prt1.Concatenate(prt2, prt1.Cond(1).OnOffsets(end), 2000);
        if runNum>2
            for r = 3:runNum
                prt2concat =  BVQXfile(fileNames.(['s' subName]).(['run' num2str(r)]).prtFileName);
                newprt = newprt.Concatenate(prt2concat, newprt.Cond(1).OnOffsets(end),2000);
            end
        end
        newprtFilePattern = regexp(prtFilePattern,'\*','split');
        newprtFilePattern= regexp(newprtFilePattern{end}, '\.prt', 'split');
        newprtFileName = fullfile(fileparts(fileNames.(['s' subName]). ...
            (['run' num2str(1)]).prtFileName), [subName, newprtFilePattern{1} '_concat.prt']);
        newprt.SaveAs(newprtFileName);
    end
    % concat vtcs:
    vtclist = cell(1,length(runNum));
    for r = 1:4
        vtclist{r} = BVQXfile(fileNames.(['s' subName]).(['run' num2str(r)]).vtcFileName);
        vtclist{r}.VTCData = zscore(vtclist{r}.VTCData);
    end
    newvtcFilePattern = regexp(vtcFilePattern,'\*','split');
    newvtcFilePattern = regexp(newvtcFilePattern{end}, '\.vtc', 'split');
    newvtcFileName = fullfile(subjectFolders{s}, [subName, '_' newvtcFilePattern{1} '_concat.vtc']);
    newvtc = vtc_concat(newvtcFileName, vtclist);
    
    %% 3. run ICA
    %newvtc = BVQXfile(fullfile(subjectFolders{s}, [subName '_TAL_concat.vtc']);
    opts.mask = BVQXfile(fileNames.(['s' subName]).mask);
    ica = newvtc.ICA([opts]);
    icaFileName = fullfile(subjectFolders{s}, [subName, '_' newvtcFilePattern{1} '_concat.ica']);
    ica.SaveAs(icaFileName);
    
    %% cleanup memory
    root=BVQXfile();
    root.ClearObjects('prt')
    root.ClearObjects('vtc')
    root.ClearObjects('msk')

end
end

