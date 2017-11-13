function checkoutResults

%%%% load results
% load('autoResults.mat')
load('autoResultsStdSet.mat')



fidNames = {'qrs_start', 'qrs_end','t_start', 't_peak','t_end'};
filenameTags = {'Run0136-b10-all.mat', 'Run0136-b15-all.mat',    'Run0136-b16-all.mat',...
    'Run0136-b20-all.mat',    'Run0136-b21-all.mat',  'Run0136-b24-all.mat',    'Run0136-b4-all.mat',...
    'Run0136-b6-all.mat'    'Run0136-b7-all.mat'  'Run0136-b9-all.mat'};
numRepetetion = 3;





[fid3D, fidNames, filenameTags, numRepetetion] = getFid3DarrayFromResults(results);





%%%% now get the means and variances
meansAcrossRepetition= zeros(length(filenameTags), length(fidNames));
variancesAcrossRepetition = zeros(length(filenameTags), length(fidNames));

for tagIdx = 1:length(filenameTags)
    for fidIdx = 1:length(fidNames)
        meansAcrossRepetition(tagIdx,fidIdx) = mean( fid3D(fidIdx, tagIdx, :)  );
        variancesAcrossRepetition(tagIdx,fidIdx) = std( fid3D(fidIdx, tagIdx, :)  );
    end
end




meansAcrossRepetition
variancesAcrossRepetition


meanOfeachFid = mean(meansAcrossRepetition,1)
varianceOfeachFid = mean(variancesAcrossRepetition,1)


% save('statistics', 'meansAcrossRepetition', 'variancesAcrossRepetition', 'meanOfeachFid', 'varianceOfeachFid')







