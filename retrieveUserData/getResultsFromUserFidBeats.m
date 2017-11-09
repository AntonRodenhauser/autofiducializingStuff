function results = getResultsFromUserFidBeats(ProcessingDataPath, ScriptDataPath,PathToPFEIFER_lightOutput, varargin)
% get the 'results' structure from beats done via PFEIFER_light using the helper files.
% SYNTAX:
%    results = getResultsFromUserFiducializedBeats(ProcessingDataPath, ScriptDataPath,PathToPFEIFER_lightOutput)
%    results = getResultsFromUserFiducializedBeats(ProcessingDataPath, ScriptDataPath,PathToPFEIFER_lightOutput, Fildname1, FieldnameValue1, Fieldname2, FieldnameValue2, ...)
% INPUTS:
%   - ProcessingDataPath:  the full path to a valid Processing Data File
%   - ScriptDataPath:  the full path to a valid Script Data File
%   - PathToPFEIFER_lightOutput:  the full path to the PFEIFER_light output folder
%   - Fieldname: a string whose value is the fieldname of a field you want to add to the results structure
%   - FieldnameValue: the value you want results.Fieldname to have..
%
%   the Fildname1,FieldnameValue1, Fieldname2, FieldnameValue2, ... inputs musst be in pairs: A FieldnameValue for each Fieldname
%
% OUTPUTS:
%   - results:  a struct in the 'typical results format'. The fields and their meanings are the same
%     Some fields are missing, though. It only has the fields:
%       - fiducials
%       - beatFileName
%       - settings  (with bad leads and group leads.. Obviously no autofiducial settings)


if ~exist(ProcessingDataPath,'file') || ~exist(ScriptDataPath,'file')
    disp('ERROR: Paths don''t exist')
    error('invalid helper file paths')
end

load(ProcessingDataPath)
load(ScriptDataPath);

if ~exist('PROCESSINGDATA','var') || ~exist('SCRIPTDATA','var')
    disp('ERROR: paths do not contain a PROCESSINGDATA and SCRIPTDATA variable')
    error('invalid helper files')
end

%%%% assemble settings structure
settings.leadsOfAllGroups = [SCRIPTDATA.GROUPLEADS{SCRIPTDATA.CURRENTRUNGROUP}{:}];
settings.badLeads = SCRIPTDATA.GBADLEADS{SCRIPTDATA.CURRENTRUNGROUP};


%%%% preallocate results
numEntries = length(PROCESSINGDATA.FILENAME);
results(numEntries) = struct('beatFileName',[], 'fiducials',[], 'settings',[], 'filenameTag',[]);

%%%% get the dictionary to translate between filename and filenameTag
dictionary = getDictionaryFromFolder(PathToPFEIFER_lightOutput);
filenames = {dictionary.filename};

%%%% loop through entries in PROCESSINGDATA and assemble results
for p =  1:numEntries
    results(p).beatFileName = PROCESSINGDATA.FILENAME{p};
    results(p).fiducials = PROCESSINGDATA.FIDS{p};
    results(p).settings = settings;
    
    correctedFilename = [PROCESSINGDATA.FILENAME{p}(1:end-4) '-all'  PROCESSINGDATA.FILENAME{p}(end-3:end)];   % to do replace with group extension form ScriptData
    
    indeces = find(  strcmp(correctedFilename, filenames)   );
    results(p).filenameTag = dictionary(indeces(1)).original_file_name;
    for q = 1:2:length(varargin)
        results(p).(varargin{q}) = varargin{q+1};
    end
end
