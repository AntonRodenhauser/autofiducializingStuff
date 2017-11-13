function results = driver_autofiducialize
% use this function to autofiducialize single beatFiles using a seedFile and the settings set in this script
% the output 'results' is a [1 x totalNumOfBeatFiles struct array] with the fields:
%   - seedFilePath: this contains the full path to the seed file used
%   - beatFilePath: this contains the full path to the beat file
%   - seedFileName: filename of the seedFile used
%   - beatFileName: filename of the beatFile
%   - fiducials: this holds the fids structure belonging to beatFile. It will be generated via autofiducializing the beatFile using seedFile
%   - settings: this contains a struct called 'settings'. In it, all the settings for autofiducializing will be stored. It has the fields
%            - numLeadsToBeFiducialised:   the number of leads that it will use for autofiducialising
%            - leadsOfAllGroups: enter all the leads of potvals that are relevant here,  usually this should be set to:    leadsOfAllGroups = 1:size(potvals,2)
%            - demandedLeads:  the leads that should definitely used for autoprocessing. In the PFEIFER gui, you would enter them in the 'Leads for Autoprocessing' text field.
%            - badLeads: the badleads, in the 'global all leads of potvals' frame (as opposed to the 'group frame' in which u enter them in PFEIFER;
%            - fidsKernelLength
%            - window_width
%            - leadsToAutofiducialize:  the leads that will be used to autofiducialize.
%   - infostring: a string that you determine in this function. It can be anything you want to note about the results..
%
% % NOTE: None of the files given in this function are changed in any way using this function, they are just loaded..



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% hard coded stuff              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% edit this to do what you want %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%  settings for fiducial detection %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% accuracy = 0.9;  % abort condition for beat envelope detection
fidsKernelLength = 10;  % it will be: kernel_indices = [fidsValue-fidsKernelLength : fidsValue+fidsKernelLength]
% to find a fid with a certain fidvalue, the kernel will be:  kernel = potvals(kernel_indices,:)
window_width = 20;   % dont search complete beat, but only a window potvals(ws:we,:) with
% ws=bs+loc_fidsValues(fidNumber)-window_width;  
% we=bs+loc_fidsValues(fidNumber)+window_width;
% windowFrames = [ws:we]

%%%%% parameters to determine which leads to use for autofiducializing
numLeadsToBeFiducialised = 10;  % the number of leads that it will use for autofiducialising
leadsOfAllGroups = 1:247;     % enter all the leads of potvals that are relevant here,  usually this should be set to:    leadsOfAllGroups = 1:size(potvals,2)
demandedLeads = [3 10 20];    % the leads that should definitely used for autoprocessing. In the PFEIFER gui, you would enter them in the 'Leads for Autoprocessing' text field.
badLeads = [140 154 157 211 540:547];    % the badleads, in the 'global all leads of potvals' frame (as opposed to the 'group frame' in which u enter them in PFEIFER;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% determine the seed files %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

folderToSeedFile1 = '/Users/anton/Documents/StudyResults/WilsonsFiducialisedBeats/sourceInputFiles';
seedFileName1 = 'Run0136-cs.mat';
fullPathSeedFile1 = fullfile(folderToSeedFile1,seedFileName1);

% folderToSeedFile2 = '/Users/anton/Documents/StudyResults/WilsonsFiducialisedBeats/sourceInputFiles';
% seedFileName2 = 'Run0136-cs.mat';
% fullPathSeedFile2 = fullfile(folderToSeedFile2,seedFileName2);

% folderToSeedFile3 = '/Users/anton/Documents/StudyResults/WilsonsFiducialisedBeats/sourceInputFiles';
% seedFileName3 = 'Run0136-cs.mat';
% fullPathSeedFile3 = fullfile(folderToSeedFile3,seedFileName3);


% assemble allSeedFiles: This is the only necessary result of this section!
% allSeedFiles musst be a [1 x nSeedFiles cell array] with the full paths to seed files

% allSeedFiles = {fullPathSeedFile1, fullPathSeedFile2, fullPathSeedFile3};
allSeedFiles = {fullPathSeedFile1};



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% determine the beat files %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

folderToBeatFiles1 = '/Users/anton/Documents/StudyResults/WilsonsFiducialisedBeats/lightInputDir';
beatFilenames1 = getAllMatFilesFromFolder(folderToBeatFiles1);
fullPathBeatFiles1 = strcat(folderToBeatFiles1,filesep,beatFilenames1);

% folderToBeatFiles2 = '/Users/anton/Documents/StudyResults/WilsonsFiducialisedBeats/lightInputDir';
% beatFilenames2 = getAllMatFilesFromFolder(folderToBeatFiles2);
% fullPathBeatFiles2 = strcat(folderToBeatFiles2,filesep,beatFilenames2);

% folderToBeatFiles3 = '/Users/anton/Documents/StudyResults/WilsonsFiducialisedBeats/lightInputDir';
% beatFilenames3 = getAllMatFilesFromFolder(folderToBeatFiles3);
% fullPathBeatFiles3 = strcat(folderToBeatFiles3,filesep,beatFilenames3);


% assemble allBeatFiles: This is the only necessary result of this section!
% allBeatFiles musst be a [1 x nSeedFiles cell array] where each entry is another cell array containing
% the full paths to beatFiles
% example:  allBeatFiles = { {beatFile1_1 , beatFile1_2}, {{beatFile_2_1}, {beatFile3_1 , beatFile3_2,  beatFile3_3} }
% the beatFile1_* will be autofiducialized using seedFile1, the beatFile2_* will be autofiducialized using seedFile2, ... 


% allBeatFiles = {fullPathBeatFiles1, fullPathBeatFiles2, fullPathBeatFiles3};
allBeatFiles = {fullPathBeatFiles1};




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% set infostring %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

infostring = '';



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% begin of actuall code    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% do not edit from here on %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



global testing
testing = 1;
if testing
    disp('WARNING: running in testing mode')
end


%%%% preallocate the results struct

% count the total number of beatFiles
numBeatFiles = 0;
for p=1:length(allBeatFiles)
    for q=1:length(allBeatFiles{p})
        numBeatFiles = numBeatFiles + 1;
    end
end
% initialise empty fields
results = struct('seedFilePath',[], 'beatFilePath',[], 'seedFileName',[], 'beatFileName',[], 'fiducials',[], 'settings',[], 'infostring',[] );

% make results numBeatFiles long
results(numBeatFiles).seedFilePath = [];



%%%%%% set up the settings structure
settings.fidsKernelLength = fidsKernelLength;
settings.window_width = window_width;
settings.numLeadsToBeFiducialised = numLeadsToBeFiducialised;
settings.leadsOfAllGroups = leadsOfAllGroups;
settings.demandedLeads = demandedLeads;
settings.badLeads = badLeads;
settings.leadsToAutofiducialize = getLeadsToAutoprocess(settings.numLeadsToBeFiducialised, settings.leadsOfAllGroups, settings.demandedLeads, settings.badLeads);


h  = waitbar(0,'autofiducializing files...');
count = 1;
for seedFileIdx = 1:length(allSeedFiles)
    %%%% get the allFids of one seedFile
    beatFileFids = getFidsOfBeatsBasedOnSeed(allSeedFiles{seedFileIdx}, allBeatFiles{seedFileIdx},settings);
    
    %%%% now loop through the beatFiles and assemble the results
    [seedFilePath, seedFileName,~] = fileparts(allSeedFiles{seedFileIdx});
    for beatFileIdx = 1:length(allBeatFiles{seedFileIdx})
        [beatFilePath, beatFileName,ext] = fileparts(allBeatFiles{seedFileIdx}{beatFileIdx});
        
        
        results(count).seedFilePath = seedFilePath;
        results(count).beatFilePath = beatFilePath;
        results(count).seedFileName = [seedFileName, ext];
        results(count).beatFileName = [beatFileName, ext];
        results(count).fiducials = beatFileFids{beatFileIdx};
        results(count).settings = settings;
        results(count).infostring = infostring;
        
        if isgraphics(h), waitbar(count/numBeatFiles,h); end
        count = count + 1;
    end
end
if isgraphics(h), close(h); end


%%%% add the filename Tags
results = addFilenameTags(results);



%%%% save results
disp('results saved in current folder')
save('results','results')














