function exportImages() {
	var doc = fl.getDocumentDOM();
	if (!doc) {
		alert("No doc.");
		return;
	}

    var libraryItems = doc.library.items;
    if (!libraryItems.length) {
        alert("The library is empty.");
        return;
    }

	var folder = fl.browseForFolderURL("Choose an output directory.");
	if (!folder) {
		alert("No output folder");	
		return;
	}

	folder = folder + "/images/";
    if (!FLfile.exists(folder)) {
        FLfile.createFolder(folder);
    }

	var i, t, sym, bmpName;
	var count = 0;

	for (i = 0; i < libraryItems.length; i++) {
		sym = libraryItems[i];
		if (sym.itemType != "bitmap") {
			continue;
		}
		bmpName = sym.name.split("/").pop();
		// strip original extension
		t = bmpName.lastIndexOf(".");
		if (t != -1 && ["jpg", "jpeg", "png", "gif", "bmp", "psd"].indexOf(bmpName.substr(t + 1).toLowerCase()) != -1) {
			bmpName = bmpName.substr(0, t);
		}
		// do the thing
		sym.exportToFile(folder + "/" + bmpName + "." + (sym.compressionType == "photo" ? "jpg" : "png"));
		count++;
	}
	alert(count + " image(s) exported, out of total of " + libraryItems.length);
}

exportImages();