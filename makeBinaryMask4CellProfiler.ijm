// makeBinaryMask4CellProfiler.ijm
// This macro is used to convert the ring prediction images into binarized mask images readable in CellProfiler
// Note: Please first open the gray-level ring prediction image (e.g. 'Example_DetectedRings.tif')
// Amin Zehtabian, Freie Universität Berlin
// amin.zehtabian@fu-berlin.de

id_OriginaStack = getImageID;
Title_OriginaStack = getTitle;
dir = getDir("image"); 
setOption("ScaleConversions", true);
run("8-bit");
run("Find Edges");
setAutoThreshold("Huang dark");
run("Threshold...");
setThreshold(9, 255);
run("Convert to Mask");
run("Fill Holes");
saveAs("tif", dir  + Title_OriginaStack + "_BW");
close("*");
