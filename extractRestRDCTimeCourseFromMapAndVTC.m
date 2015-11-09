function ct = extractCLUSTERTimeCourseFromMapAndVTC(cNum, rootdir, vtc, s, params)
% get the mean time course off all voxels in a Rodriguez cluster
% Inputs:
% cNum    - cluster index
% rootdir - of vmp
% vtc     - of task
% params

vmpname = findFilesBVQX([rootdir 'analysis\Rodriguez\cut_off_' params.rodclust.cutoff ...
    '_clusters' params.rodclust.size '\'], [s '*' params.rodclust.halo '.vmp'],  ...
    struct('maxdepth',2));

vmp = BVQXfile(vmpname{1});

cluster_map = vmp.Map(cNum).VMPData;
m(1,:,:,:) = cluster_map;
ct = zeros(1,size(vtc,1));
for t = 1:size(vtc,1)
    ct(t) = sum(sum(sum(vtc(t,:,:,:).* m)));
end
ct = zscore(ct);




% subplot(2,1,1), plot(zscore(ica.Map(icNum).TimePointData), 'red');
% subplot(2,1,2), plot(ct, 'blue');
