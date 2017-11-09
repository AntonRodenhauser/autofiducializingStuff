function data = getDataFromResults(results, what, varargin)
% retrieve data in various ways from the 'results' structure
%
% SYNTAX:
%     data = GETDATAFROMRESULTS(results,what)
%     data = GETDATAFROMRESULTS(results,what, 'Fieldname1', 'FieldnameVallue1', 'Fieldname2', 'FieldnameValue2', ...)
%
% DESCRIPTION:
%     data = GETDATAFROMRESULTS(results,what)  returns a (cell) array containing what you want ('what')
%     of all entries in results
%
%     data = GETDATAFROMRESULTS(results,what, 'Fieldname1', 'FieldnameVallue1', 'Fieldname2', 'FieldnameValue2', ...)  
%     returns a (cell) array containing what you want ('what') of all entries in results where
%     [results.Fieldname1] == FieldnameVallue1 and [results.Fieldname2] == FieldnameVallue2 and ...
%
% EXAMPLES:
%     GETDATAFROMRESULTS(results,'qrs_start') returns an array with all qrs_start values
%
%     GETDATAFROMRESULTS(results,'indices', 'seedFileName', 'seedFileNameValue') returns an array with all indices
%     of results where [results.seedFileName] == 'seedFileNameValue'
%
%     GETDATAFROMRESULTS(results,'fiducials', 'seedFileName', 'seedFileNameValue', 'beatFileName', 'seedFileNameValue' )
%     returns a cell array with the fids in results where [results.seedFileName] == 'NameOfSeedFile'
%     and [results.beatFileName] == 'beatFileNameValue'
%
% INPUTS:
%     what: a string describing what you want. Can be one of the following:
%           - any of the fieldnames of the 'results' struct. the 'common' fields are:
%               - seedFilePath'
%               - 'beatFilePath'
%               - 'seedFileName'
%               - 'beatFileName'
%               - 'fiducials'
%               - 'settings'
%               - 'infostring'
%               - 'filenameTag'
%           - one of the fiducials from the fids structure:
%               - 'qrs_start'
%               - 'qrs_peak'
%               - 'qrs_end'
%               - 'p_start'
%               - 'p_end'
%               - 't_start'
%               - 't_peak'
%               - 't_end'
%               - 'x_start'
%               - 'x_peak'
%               - 'x_end'
%           - 'indices'    in this case the indices of results are returned
%
%     Fieldname1,Fieldname2,...    A string with one of the following fieldnames of results
%               - seedFilePath'
%               - 'beatFilePath'
%               - 'seedFileName'
%               - 'beatFileName'
%               - 'settings'
%               - 'infostring'
%
%     FieldnameValue1, FieldnameValue2,...     A possible value of Fieldname1,Fieldname2, ...
%
% OUTPUTS:
%   -data:  either an array or a cell array with the data you want

%%%% get the indices that fullfil conditions
indices = 1:length(results);
if ~isempty(varargin)
    for p=1:2:length(varargin)
        if ~isfield(results,varargin{p})
            disp('ERROR: Fieldname is invalid. There is no such Fieldname in ''results''.')
        end
        newIndices = find(strcmp({results.(varargin{p})},varargin{p+1}));
        indices = intersect(indices, newIndices);
    end
end
        
fidType = [];
switch what
    case 'indices'
        data = indices;
    case {'seedFilePath','beatFilePath','fiducials','settings','infostring','seedFileName','beatFileName'}
        data = {results(indices).(what)};
    case 'qrs_start'
        fidType =  2;
    case 'qrs_peak'
        fidType =  3;
    case 'qrs_end'
        fidType =  4;
    case 'p_end'
        fidType =  1;
    case 'p_start'
        fidType =  0;
    case 't_start'
        fidType =  5;
    case 't_end'
        fidType =  7;
    case 't_peak'
        fidType =  6;
    case 'x_start'
        fidType =  26;
    case 'x_peak'
        fidType =  25;
    case 'x_end'
        fidType = 27;
    otherwise
        disp('ERROR: invalid input for ''what''.')
        error('invalid input for second input argument.')
end


if ~isempty(fidType)
    data = zeros(1,length(indices));
    allFids = {results(indices).fiducials};
    for p=1:length(allFids)
        fids = allFids{p};
        fidIdx = find(fidType == [fids.type]);
        if length(fidIdx) < 1
            fprintf('ERROR: The fiducial %s does not exist in the fid structure in entry %d of the results structure\n',what,p)
            error('Fiducial not found')
        elseif length(fidIdx) >1
            fprintf('ERROR: There are multiple entries  of fiducial %s in the fid structure in entry %d of the results structure\n',what,p)
            error('multiple instances of same fiducial in fid structure. Get rid of individual fids?')
        end        
        data(p) = fids( fidIdx ).value;
    end
end

        
        
        
        
        