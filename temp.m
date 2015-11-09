%% temp

%test on msk
msk = BVQXfile('D:\study 6 - ICs based classification\data\DM\anatomy\STG_test.msk');
[r,c,v] = ind2sub(size(msk.Mask),find(msk.Mask == 1));

% plot 1 voxel in mask:
v1 = vtc1(:,r(1),c(1),v(1));
v2 = vtc2(:,r(1),c(1),v(1));
v3 = (zscore(v1)+zscore(v2))./2; % mean time course
plot(zscore(v1))
hold on; plot(zscore(v2), 'r');
hold on; plot(v3, 'g'); 
hold on; plot_prt(p,[-4 4]);
