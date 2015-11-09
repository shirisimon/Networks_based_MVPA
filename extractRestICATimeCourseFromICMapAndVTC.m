function ct = extractRestICATimeCourseFromICMapAndVTC(icNum, rootdir, vtc, s, ...
    params)

if ~params.ica.sogica
    rest1 = findFilesBVQX([rootdir 'data\' s '\rest1\'],'*rest1*_TAL.ica',struct('maxdepth',1) );
    ica = BVQXfile(rest1{1});
else 
    ica = BVQXfile([pwd, '\sogICA_bv_rest\IND_SogICA_10Subjs_1stRest_27ICs.ica']);
end

if ~params.ica.inverse_polarity
    ic_map = ica.Map(icNum).CMPData;
else
    ic_map = (-1)*ica.Map(icNum).CMPData;
end

% align vtc and ic maps:
% [vtc_data, ic_map] = alignVTCandICMaps(vtc, ica);

m(1,:,:,:) = ic_map; 
ct = zeros(1,size(vtc,1)); 
for t = 1:size(vtc,1)
    ct(t) = sum(sum(sum(vtc(t,:,:,:).* m)));
end
ct = zscore(ct);

% subplot(2,1,1), plot(zscore(ica.Map(icNum).TimePointData), 'red');
% subplot(2,1,2), plot(ct, 'blue');