function results = addFilenameTags(results)

%%%% get the dictionary to translate between filename and filenameTag
dictionary = getDictionaryFromFolder(results(1).beatFilePath);
filenames = {dictionary.filename};

filenameTag = {dictionary.original_file_name};




for p=1:length(results)
    idx = strcmp(filenames, results(p).beatFileName);
    results(p).filenameTag = filenameTag{idx};
end