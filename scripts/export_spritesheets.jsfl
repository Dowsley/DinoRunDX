function exportSpriteSheets() {
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

    folder = folder + "/spritesheets/";
    if (!FLfile.exists(folder)) {
        FLfile.createFolder(folder);
    }

    var count = 0;

    for (var i = 0; i < libraryItems.length; i++) {
        var item = libraryItems[i];
        if (item.itemType === "movie clip") {
            // This will export all frames of the movie clip.
            fl.trace('Trying to export ' + item.name + '\n');
            var exportName = folder + "/" + item.name.split('/').pop();
            var exporter = new SpriteSheetExporter()
            exporter.beginExport();
            exporter.addSymbol(item)
            exporter.exportSpriteSheet(exportName, {format:"png", bitDepth:32, backgroundColor:"#00000000"})
            // item.exportToPNGSequence(exportName);
            fl.trace(item.name + ' successful ' + '\n');
            // fl.trace(item.name + ' failed due to ' + e + '\n');
            count++;
        }
    }

    alert(count + " movie clip(s) exported as PNG sequences.");
}

exportSpriteSheets();
