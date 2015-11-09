%% feature_selection_with_pca

% generate dataA, dataB from 'main_runICsSVMBatch.m'

mat = [dataA; dataB];
[coeff, scores, latent] = pca(mat);
