function results = driver_getResultsFromUser
% this function is the driver function to assemble the results structure
% from fiducials done by a User using PFEIFER_light


%%%% set paths to the helper files of PFEIFER_light
ProcessingDataPath = '/Users/anton/Documents/StudyResults/WilsonsFiducialisedBeats/helperFiles_light/ProcessingData.mat';
ScriptDataPath = '/Users/anton/Documents/StudyResults/WilsonsFiducialisedBeats/helperFiles_light/ScriptData.mat';
PathToPFEIFER_lightOutput = '/Users/anton/Documents/StudyResults/WilsonsFiducialisedBeats/lightOutputDir';


infostring = 'the fiducials done by Wilson';




results = getResultsFromUserFidBeats(ProcessingDataPath, ScriptDataPath,PathToPFEIFER_lightOutput, 'infostring', infostring);

