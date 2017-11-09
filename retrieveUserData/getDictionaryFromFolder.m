function dictionary = getDictionaryFromFolder(folder)
files = getAllMatFilesFromFolder(folder);

dictionary(length(files)) = struct('filename',[],'original_file_name',[]);
for p=1:length(files)
    load(fullfile(folder,files{p}))
    dictionary(p).filename = ts.filename;
    dictionary(p).original_file_name = ts.original_file_name;
end
