function allFids = getFidsOfBeatsBasedOnSeed(seedFile, beatFiles,settings)
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

%%%% check if window 'to big'
if 2 * window_width +1 > nFrames
    disp('ERROR: window_width to high. Window does not fit into beat')
    error('window_width to high')
end

%%%% get the oriFids, the fids that we want to autofiducialize, from fiducialized_ts,  clear any non-global fids from it
if isfield(seedTS,'fids')
    [fidTypes, fidValues] = getFidsTypesAndValuesFromFids(seedTS.fids);
else
    disp('ERROR: the seedFile does not contain ts.fids.')
    error('no ts.fids in seedFile')
end

nFids=length(fidTypes);


%%%% set up the fsk ("fiducial start kernel")  and fek, make sure they are not out of range
fsk = fidValues - fidsKernelLength;   % fiducial start kernel,  the index in potvals where the kernel for fiducials starts
fek = fidValues + fidsKernelLength;   % analog to fsk, but 'end'
% make sure kernel not out of range..
for fidIdx = 1:length(fidValues)
    if fsk(fidIdx) < 1  % if kernel 'to far left', shift it to the right!
        shift = - fsk(fidIdx) + 1;
        fsk(fidIdx) = 1;
        fek(fidIdx) = fek(fidIdx) + shift;
    elseif fek(fidIdx) > nFrames  % if kernel 'to far right', shift it to the left!
        shift = nFrames - fek(fidIdx);
        fsk(fidIdx) = fsk(fidIdx) + shift;
        fek(fidIdx) = nFrames;
    end
end

%%%% get window start/end indeces for each fid
bs = 1; % in this case beat start is always 1
ws=bs+fidValues-window_width;  %window start indeces
we=bs+fidValues+window_width;  %window end indeces
for fidIdx = 1:length(fidValues)
    if ws(fidIdx) < 1  % if window 'to far left', shift it to the right!
        shift = - ws(fidIdx) + 1;
        ws(fidIdx) = 1;
        we(fidIdx) = we(fidIdx) + shift;
    elseif we(fidIdx) > nFrames  % if window 'to far right', shift it to the left!
        shift = nFrames - we(fidIdx);
        ws(fidIdx) = ws(fidIdx) + shift;
        we(fidIdx) = nFrames;
    end
end

% %%%% shift the kernel/window for t_start by 20
% tStartIdx = find(fidTypes == 5);
% fsk(tStartIdx) = fsk(tStartIdx) + 20;
% fek(tStartIdx) = fek(tStartIdx) + 20;
% disp('shifting t_kernel by 20')


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





global testing
disp('remove this')



%%%%%%%%%%%%% get fids %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
fids = struct('type',[],'value',[]);
if nFids == 0
    return
else
    fids(nFids).type = []; %pre-allocate
end
for fidIdx=1:nFids

    %%%% set up windows
    windows=reducedBeatPotvals(:, ws(fidIdx):we(fidIdx));

    %%%% find fids
%    [winFrGlobFid, indivFids, ~] = findFid(windows,kernels(:,:,fidIdx));   % the ignored outputs here are: individual fids of the leadsToBeFiducialized and the variances..
    [winFrGlobFid, indivFids, ~] = downsample_findFid(windows,kernels(:,:,fidIdx),stepsize);   % the ignored outputs here are: individual fids of the leadsToBeFiducialized and the variances..

    locFrGlobFid=winFrGlobFid + fidValues(fidIdx) - fsk(fidIdx) + ws(fidIdx) - 1;      % put it into "complete potvals" frame

    
    %%%% add the global fid to allFids
    fids(fidIdx).type=fidTypes(fidIdx);
    fids(fidIdx).value=locFrGlobFid;
    
    
    if testing
        indFids(fidIdx).type=fidTypes(fidIdx);
        indFids(fidIdx).value=indivFids + fidValues(fidIdx) - fsk(fidIdx) + ws(fidIdx) - 1;
    end
    
end




%%%% retrieve data (for testing only!!) if not testing, comment this out
if testing
    global testdata
    testdata.fsk = fsk;
    testdata.fek = fek;
    testdata.fidsTypes = fidTypes;
    testdata.fidsValues  = fidValues;
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

    if length(rbpv) > 32
        testdata.allIndFids = allIndFids;
        testdata.allFids = allFids;
        testdata.beatFilenames = beatFilenames;
        testdata.filenameTag = filenameTag;
        testdata.rbpv = rbpv;
        disp('last beat')
    end
end













