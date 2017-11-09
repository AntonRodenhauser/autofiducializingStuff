function [fid3D, fidNames, filenameTags, numRepetetion] = getFid3DarrayFromResults(results)
% puts all the fiducial values in results in a handy 3D array
% INPUTS:
%   - results: the normal results structure from user fiducialized beats
%     can be optained for example using the 'driver_getResultsFromUser' function
%     the results must have the 'fiducials' field with fids containing qrs-, and t-wave and t-peak
% OUTPUTS:
%   - fid3D:  a [numFidNames x numFilenameTags x numRepetition ] double array containing the time frames of the fiducials
%   - fidNames: cell array with fiducial names in the same order they appear along the first dimension in fid3D
%   - filenameTags: cell array with filenameTags in the same order they appear along the second dimension in fid3D
%   - numRepetion: an integer indicating how often a file with the same filenameTag was done ("how often the user fiducialized the same file")
%
% EXAMPLE USE:
%   >> [fid3D, fidNames, filenameTags, numRepetetion] = getFid3DarrayFromResults(results);
%   >> fiducialValue = fid3D(fiducialIdx, filenameTagIdx, repetitionIdx);
%      now fiducialValue is the time frame of fiducial fidNames{fiducialIdx} from the
%      repetionIdx th time the file with filenameTags{filenameTagIdx} was fiducialized.
%      

fidNames = {'qrs_start', 'qrs_end','t_start', 't_peak','t_end'};
filenameTags = unique({results.filenameTag});
numRepetetion = nnz( strcmp(filenameTags{1}, {results.filenameTag}));


%%%% get all Fids in 3-dimensional meta structure
fid3D = zeros(length(fidNames), length(filenameTags), numRepetetion);

for fidNameIdx = 1:length(fidNames)
    for filenameTagIdx = 1: length(filenameTags)
        fid3D(fidNameIdx, filenameTagIdx, : ) = getDataFromResults(results, fidNames{fidNameIdx}, 'filenameTag', filenameTags{filenameTagIdx});
    end
end



    

