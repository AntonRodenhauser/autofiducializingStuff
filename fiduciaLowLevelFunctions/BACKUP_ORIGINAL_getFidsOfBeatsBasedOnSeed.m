function allFids = BACKUP_ORIGINAL_getFidsOfBeatsBasedOnSeed(seedFile, beatFiles,settings)
% this is just a backup of the function getFidsOfBeatsBasedOnSeed in a
% working state


% this function fiducializes the beats in beatFiles using the seedTS in seedFile as a seed
% inputs:
%   - beatFiles = { filenameBeat1, filenameBeat2, ..... }        cellarrays with full paths to ts structures that contains the beatTSs we want to autofiducialize
%   - seedFile ='fullPathToSeedTS'    the path to the ts structure that has ts.fids. These fids will be used for autofiducializing the beats
%   - settings: a struct with all the settings that would normally be done by the user in the PFEIFER gui.
%     Settings musst have the following fields:
%           - leadsToAutofiducialize
%           - accuracy
%           - fidsKernelLength
%           - window_width
% outputs:
%   - filenames = { ts.fids of Beat1,  ts.fids of Beat2, ....}     the fids structures (local fids) of the beats in beats, in the same order



%%%% first, get the seedTS structure
load(seedFile)
seedTS = ts;


global testing
if testing
    clear global testdata rbpv allIndFids allFids beatFilenames filenameTag
end


%%%% autofiducialiaze
[allFids{1:length(beatFiles)}] = deal([]);
for p = 1:length(beatFiles)
    %%%% load the beatsTSs
    load(beatFiles{p})    
    allFids{p} = fiducializeSingleBeat(ts,seedTS,settings);    
    
end



function fids = fiducializeSingleBeat(beatTS,seedTS,settings)
% return the fids structure to beatTS using autofiducializing based on the fids in seedTS
% settings is a struct containing the user settings normally done by the user.

nFrames = size(beatTS.potvals,2);
window_width = settings.window_width;
fidsKernelLength = settings.fidsKernelLength;

%%%% get the oriFids, the fids that we want to autofiducialize, from fiducialized_ts,  clear any non-global fids from it
if isfield(seedTS,'fids')
    [fidsTypes, fidsValues] = getFidsTypesAndValuesFromFids(seedTS.fids);
else
    disp('ERROR: the seedFile does not contain ts.fids.')
    error('no ts.fids in seedFile')
end

nFids=length(fidsTypes);


%%%% set up the fsk and fek 
fsk = fidsValues - fidsKernelLength;   % fiducial start kernel,  the index in potvals where the kernel for fiducials starts
fek = fidsValues + fidsKernelLength;   % analog to fsk, but 'end'



%%%% now get nToBeFiducialized leads from fullPotvals,
reducedBeatPotvals = beatTS.potvals(settings.leadsToAutofiducialize,:);
reducedSeedPotvals = seedTS.potvals(settings.leadsToAutofiducialize,:);

%%%% make sure there are no bad leads in the potvals..
toBeDeleted = [];
for leadNumber=1:size(reducedBeatPotvals,1)
    if nnz(reducedBeatPotvals(leadNumber,1:10:end)) == 0
        toBeDeleted(end+1)=leadNumber;
    end
end
reducedBeatPotvals(toBeDeleted,:) = [];
reducedSeedPotvals(toBeDeleted,:) = [];

%%%% get the first kernels based on the user fiducialized beat
kernels = zeros(size(reducedSeedPotvals,1), 2*fidsKernelLength +1, nFids);
for fidIdx = 1:nFids
    kernels(:,:,fidIdx) = reducedSeedPotvals(:,fsk(fidIdx):fek(fidIdx));
end

% kernels is now nLeads x nTimeFramesOfKernel x nFids array containing all kernels for each lead for each fiducial
% example: kernel(3,:,5)  is kernel for the 3rd lead and the 5th fiducial (in fidsTypes)


%%%% get window start/end indeces for each fid
bs = 1; % in this case beat start is always 1
ws=bs+fidsValues-window_width;  %window start indeces
we=bs+fidsValues+window_width;  %window end indeces


global testing
disp('remove this (line 96 in getFidsOfBeatsBasedOnSeeds')



%%%%%%%%%%%%% get fids %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
fids = struct('type',[],'value',[]);
if nFids == 0
    return
else
    fids(nFids).type = []; %pre-allocate
end
for fidIdx=1:nFids
    %%%% set up windows
    
    if ws(fidIdx) < 1 || we(fidIdx) > nFrames
        fprintf('WARNING: Fiducial of type %s to close to beat envelope for autofiducializing. Skipping fiducial...',fidsTypes(fidIdx))
        return
    end
    windows=reducedBeatPotvals(:, ws(fidIdx):we(fidIdx));

    %%%% find fids
    [winFrGlobFid, indivFids, ~] = findFid(windows,kernels(:,:,fidIdx));   % the ignored outputs here are: individual fids of the leadsToBeFiducialized and the variances..
    locFrGlobFid=winFrGlobFid + fidsKernelLength + ws(fidIdx) - 1;      % put it into "complete potvals" frame

    
    %%%% add the global fid to allFids
    fids(fidIdx).type=fidsTypes(fidIdx);
    fids(fidIdx).value=locFrGlobFid;
    
    
    if testing
        indFids(fidIdx).type=fidsTypes(fidIdx);
        indFids(fidIdx).value=indivFids + fidsKernelLength + ws(fidIdx) - 1;
    end
    
end




%%%% retrieve data (for testing only!!) if not testing, comment this out
if testing
    global testdata
    testdata.fsk = fsk;
    testdata.fek = fek;
    testdata.fidsTypes = fidsTypes;
    testdata.fidsValues  = fidsValues;
    testdata.ws = ws;
    testdata.we =we;
    testdata.kernels = kernels;
    testdata.settings = settings;
    testdata.reducedSeedPotvals = reducedSeedPotvals;
    
    global rbpv allIndFids allFids beatFilenames filenameTag
    allIndFids{end+1} = indFids;
    allFids{end +1}  = fids;
    rbpv{end+1} = reducedBeatPotvals;
    beatFilenames{end+1} = beatTS.filename;
    filenameTag{end+1} = beatTS.original_file_name;

    if length(rbpv) > 10
        error('end it')
    end
end













