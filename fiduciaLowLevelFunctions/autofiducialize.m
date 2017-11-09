function [beatEnvelopes, allFids] = autofiducialize(ts_toBeAutofiducialized, fiducialized_ts, accuracy, fidsKernelLength, window_width, nToBeFiducialized)
% this function autofiducializes the beats in ts_toBeAutofiducialized based on the beat envelope and fids in fiducialized_ts
%
% inputs:
%   - ts_toBeAutofiducialized:  the ts structure where you want to find the beats and fiducials. ts_toBeAutofiducialized must have the fields: 'potvals'.
%   - fiducialized_ts:  the ts structure that holds the beat envelope and fiducials to be found. fiducialized_ts must have the fields 'potvals','fids' and 'selframes';
% outputs:
%   - beatEnvelopes =  {[beatStartFrame, beatEndFrame],    [beatEnvelope of 2th beat],   .... }
%   - allFids =        { ts.fids first (=original) beat,   ts.fids of 2th beat,          .... }





%%%% get the beat kernel (the template used to find the beat) from the selframes in fiducialized_ts
bsk=fiducialized_ts.selframes(1);   %start and end of beat
bek=fiducialized_ts.selframes(2);


%%%% get the oriFids, the fids that we want to autofiducialize, from fiducialized_ts,  clear any non-global fids from it
oriFids=fiducialized_ts.fids;
toBeCleared=[];
for p=1:length(oriFids)
    if length(oriFids(p).value)~=1   % if not single global value
        toBeCleared=[toBeCleared p];
    end
end
oriFids(toBeCleared)=[]; 



%%%%% get the fids done by the user (in oriFids), that will be fiducialized

% these are the possible fiducials that will be fiducialized if the user has done them
% corresponds to wave:   p    qrs   t     X               
possibleWaves =       [ 0 1   2 4  5 7  26 27 ];

% corresponds to peak: qrs    t    X
possiblePeaks =       [ 3     6    25 ];


% loop through possible Waves and see if the user did them. If yes, get their values from oriFids and add them to locFrFidsValues
fidsTypes = [];       % these will be the fid types that will be autofiduciailized... 
locFrFidsValues = []; % ...and corresponding fiducials that will be auto-fiducialized
for waveStartTypeIdx = 1:2:length(possibleWaves)
    waveStartType = possibleWaves(waveStartTypeIdx);
    waveEndType = possibleWaves(waveStartTypeIdx+1);
    
    startOriFidsIdx = find([oriFids.type]==waveStartType, 1);
    endOriFidsIdx = find([oriFids.type]==waveEndType, 1);
    
    if ~isempty(startOriFidsIdx) && ~isempty(endOriFidsIdx)   % if wave is in oriFids (ergo, was done by user)
        waveStartValue = round(oriFids(startOriFidsIdx(1)).value);  % get fids value
        waveEndValue = round(oriFids(endOriFidsIdx(1)).value);  
        fidsTypes = [fidsTypes waveStartType waveEndType];               % and put them in fidsTypes and locFrFidsValues
        locFrFidsValues = [locFrFidsValues waveStartValue waveEndValue];
    end
end
% now loop through possible peaks and do the same like with waves
for peakType = possiblePeaks    
    peakOriFidsIdx = find([oriFids.type]==peakType, 1);
    if ~isempty(peakOriFidsIdx)   % if peak is in oriFids (ergo, was done by user)
        peakValue = round(oriFids(peakOriFidsIdx(1)).value);  % get peak value
        fidsTypes = [fidsTypes peakType];               % and put them in fidsTypes and locFrFidsValues
        locFrFidsValues = [locFrFidsValues peakValue];
    end
end
nFids=length(fidsTypes);


%%%% get the globFidsValues, the fids in the "global complete signal frame"
globFrFidsValues = locFrFidsValues+bsk-1;



%%%% set up the fsk and fek 
fsk=globFrFidsValues - fidsKernelLength;   % fiducial start kernel,  the index in potvals where the kernel for fiducials starts
fek=globFrFidsValues + fidsKernelLength;   % analog to fsk, but 'end'



%%%% make sure there are no bad leads in the potvals..
fullPotvals = ts_toBeAutofiducialized.potvals;
toBeDeleted = [];
for leadNumber=1:size(fullPotvals,1)
    if nnz(fullPotvals(leadNumber,fsk(1):100:fek(1))) == 0
        toBeDeleted(end+1)=leadNumber;
    end
end
fullPotvals(toBeDeleted,:)=[];




%%%% now get nToBeFiducialized leads from fullPotvals,
leadsToAutofiducialize=round(linspace(1, size(fullPotvals,1), nToBeFiducialized));
reducedPotvals = fullPotvals(leadsToAutofiducialize,:);


%%%% get the first kernels based on the user fiducialized beat
kernels = zeros(nToBeFiducialized, 2*fidsKernelLength +1, nFids);
for fidNumber = 1:nFids
    kernels(:,:,fidNumber) = reducedPotvals(:,fsk(fidNumber):fek(fidNumber));
end
% kernels is now nLeads x nTimeFramesOfKernel x nFids array containing all kernels for each lead for each fiducial
% example: kernel(3,:,5)  is kernel for the 3rd lead and the 5th fiducial (in fidsTypes)


%%%%% find the beats, get rid of beats before user fiducialiced beat
RMSsignal = preprocessPotvals(fullPotvals);   % make signal out of leadsOfAllGroups
beatEnvelopes=findMatches(RMSsignal, RMSsignal(bsk:bek), accuracy);
% find oriBeatIdx, the index of the template beat
oriBeatIdx = [];
for beatNumber=1:length(beatEnvelopes)    
    if (abs(beatEnvelopes{beatNumber}(1) - bsk)) < 3  % if found beat "close enough" to original Beat 
        oriBeatIdx=beatNumber;
        break
    end
end

if isempty(oriBeatIdx)    % in rare cases the oriBeat is blanked out in the findMatches function. In this case, just use actuall beat
    oriBeatEnvelope = [bsk,bek];
    beatEnvelopes = [oriBeatEnvelope beatEnvelopes];
else
    beatEnvelopes = beatEnvelopes(oriBeatIdx:end);   % get rid if beats occuring before the user fiducialized beat

end
nBeats=length(beatEnvelopes);



%%%% initialice/preallocate allFids
if nFids > 0
    defaultFid(nFids).type=[];
    defaultFid(nFids).value=[];
else
    defaultFid = struct('type',[],'value',[]);
end
[allFids{1:nBeats}]=deal(defaultFid);


%%%%%%%%%%%%% fill allFids with values %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h=waitbar(0,'Autofiducializing Beats..');
for beatNumber=1:nBeats %for each beat
    bs=beatEnvelopes{beatNumber}(1);  % start of beat
    be=beatEnvelopes{beatNumber}(2);  % end of beat
    
    for fidNumber=1:nFids
        
        %%%% set up windows
        ws=bs+locFrFidsValues(fidNumber)-window_width;  % dont search complete beat, only around fid
        we=bs+locFrFidsValues(fidNumber)+window_width;
        windows=reducedPotvals(:,ws:we);
        
        %%%% find fids
        [winFrGlobFid, ~, ~] = findFid(windows,kernels(:,:,fidNumber));   % the ignored outputs here are: individual fids of the leadsToBeFiducialized and the variances..
        
        % put fids in 'local Frame' (in local Frame, the 1th frame is the beginning of beat,  as opposed to 'global frame', where the first frame is beginning of signal)
%       indivFids=winFrIndivFids + fidsKernelLength + locFrFidsValues(fidNumber) - window_width;  % now  newIndivFids is in "complete potvals" frame.
        locFrGlobFid=winFrGlobFid + fidsKernelLength + locFrFidsValues(fidNumber) - window_width;      % put it into "complete potvals" frame

        
        %%%% if fids are outside of beat, make beat larger to fit fiducial
        if locFrGlobFid > (be-bs) +1
            AUTOPROCESSING.beats{beatNumber}(2)=locFrGlobFid + bs + 2;
        elseif locFrGlobFid < 1
            AUTOPROCESSING.beats{beatNumber}(1)= locFrGlobFid + bs - 1;
            locFrGlobFid = 1;
        end

        %%%% add the global fid to allFids
        allFids{beatNumber}(nFids+fidNumber).type=fidsTypes(fidNumber);
        allFids{beatNumber}(nFids+fidNumber).value=locFrGlobFid;         
    end
    if isgraphics(h), waitbar(beatNumber/nBeats,h), end
end
if isgraphics(h), delete(h), end








function [globFid, indivFids, variance] = findFid(windows,kernels)
% inputs:
%   - windows:  a nLeads x length(window) - array with all the windows of a beat
%   - kernels: a nLeads x length(kernel) - array with all the kernels of one fiducial
%
% outputs:
%   - gobalFid: idx of global fids, determined by taking mode from indivFids 
%   - indivFids: indeces of individual fids,    indivFids=lag(index))+1 (= index!)   this way   windows(indivFids:indivFids+length(kernel)-1) matches kernel best;
%     this means, indivFids still needs to be shiftet to the point in kernel, where the actuall fid is.
%   - indivXcorr: nLeads x 1 array with normalised xcorr values of matches


nLeads=size(kernels,1);
length_kernel=size(kernels,2);
lagshift=0;
numlags=size(windows,2)-length_kernel+1;   %only the lags with "no overlapping"

xc=zeros(nLeads,numlags);   %the cross correlation values
for leadNumber=1:nLeads 
    for lag=1:numlags
        xc(leadNumber,lag)=xcorr(windows(leadNumber,lag:lag+length_kernel-1), kernels(leadNumber,:),lagshift,'coef');
    end 
end
[~,indivFids]=max(xc,[],2);

% now compute the globalFid by computing the "Mode": sum up all xc-values of a lag and find the max of the summed up xc-values
[~,globFid]=max(sum(xc,1),[],2);
% variance
variance=var(indivFids);

function signal = preprocessPotvals(potvals)
% do temporal filter and RMS, to get a signal to work with

%%%% temporal filter
A = 1;
B = [0.03266412226059 0.06320942361376 0.09378788647083 0.10617422096837 0.09378788647083 0.06320942361376 0.03266412226059];

D = potvals';
D = filter(B,A,D);
D(1:(max(length(A),length(B))-1),:) = ones(max(length(A),length(B))-1,1)*D(max(length(A),length(B)),:);
potvals = D';

%%%% do RMS
signal=sqrt(mean(potvals.^2));
signal=signal-min(signal);

