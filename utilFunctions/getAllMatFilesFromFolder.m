function filenames = getAllMatFilesFromFolder(folder)

metaFolder = dir(fullfile(folder, '*.mat'));
metaFolder( [metaFolder.isdir] ) = [];
filenames = {metaFolder.name};
