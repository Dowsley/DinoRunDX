function exportAudio() {
    var doc = fl.getDocumentDOM();
    if (!doc) {
        alert("No document open.");
        return;
    }

    var libraryItems = doc.library.items;
    if (!libraryItems.length) {
        alert("The library is empty.");
        return;
    }

    var folder = fl.browseForFolderURL("Select the output directory.");
    if (!folder) {
        alert("No output folder selected.");
        return;
    }

    folder = folder + "/audio/";
    if (!FLfile.exists(folder)) {
        FLfile.createFolder(folder);
    }

    var count = 0;
    for (var i = 0; i < libraryItems.length; i++) {
        var libItem = libraryItems[i];
		if (libItem.itemType == "bitmap" || libItem.itemType == "sound") 
		{
			// Check the audio files original Compression Type if "RAW" export only as a .wav file
			// Any other compression type then export as the libItem's name defines.
			if(libItem.itemType == "sound" && libItem.originalCompressionType == "RAW")
			{
				wavName = libItem.name.split('.')[0]+'.wav';
				imageFileURL = folder + "/" + wavName;
			} else {
				imageFileURL = folder + "/" + libItem.name;
			}
			var success = libItem.exportToFile(imageFileURL);
		}
    }
}

exportAudio();
