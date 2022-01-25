// RingSizeMacro_v1.1
// Notes: (1) Please first open the image containing the 'average ring' (e.g. 'Example_AverageRing.tif')
//        (2) Feel free to set the optional parameters ChoiceEdge, ChoiceManual, ChoiceRotation, and ChoiceProfile to get desired outcome
// Amin Zehtabian, Freie Universität Berlin
// amin.zehtabian@fu-berlin.de

macro "RingSizeMacro_v1.1" {
	saveSettings;
	run("Clear Results");
  	run("Select None");
	id_OriginaStack = getImageID;
    Title_OriginaStack = getTitle;
    dir = getDir("image"); 
    width = getWidth; height = getHeight; depth = nSlices; 
    //File.makeDirectory(dir + "Profile Lines"); 
    //outputFolder = dir + "Profile Lines";         
    run("Duplicate...", " ");
	id_tobeRotated = getImageID;
    Title_tobeRotated = getTitle;        
	
	// Set ChoiceEdge to 1 for edge detection, then manually draw the first profile line on the edge-detected image
	// Set ChoiceEdge to 0 if you do not to check the edges of the average ring before drawing the profile lines
	ChoiceEdge = 0;
	if (ChoiceEdge==1) {
    	run("Duplicate...", " ");
    	print("Edge detection is done!");
		setOption("BlackBackground", false);
		run("Make Binary"); 	run("Fill Holes"); 	run("Find Edges");
		id_toDrawLine = getImageID;   // the profile line will be later drawn on the edge-detected average ring image
        Title_toDrawLine = getTitle;        
	}
	else if (ChoiceEdge==0) {
    	print("Edge detection is NOT being done!");	
    	run("Duplicate...", " ");
    	id_toDrawLine = getImageID;  // the profile line will be later drawn on the average ring image
        Title_toDrawLine = getTitle;
	}

    // Set ChoiceManual to 1 if you desire to manually draw the initial profile line. This would be adviced where the peak-to-peak distance(s) are wrongly calculated due to presence of noisy or incomplete average rings 
    // Set ChoiceManual to 0 to ask the software to automatically find the center of ring and then to draw the initial profile line
    // In both cases, the rest of the lines will be automatically drawn 
	ChoiceManual = 0;
	print(Title_toDrawLine);
	selectWindow(Title_toDrawLine);
	if (ChoiceManual==1) {
		waitForUser("User Action Required!", "Manually draw the first profile line, then press 'Ok'! (hint: hold 'Shift' key down for drawing a straight line!)");  //wait for user action
	}
    else if (ChoiceManual==0) {
    	//selectWindow(Title_toDrawLine);
    	makeLine(0, round(height/2), width-1, round(height/2));    	
    }
    wait(1000);
   	selectWindow(Title_tobeRotated);
   	run("Restore Selection");
   	
    //
    // getPixelSize(unit, pw, ph, pd);		// To extract the Pixel size from metadata
    pw = 10;   // Pixel size (to set manually)
	nPlots = 18;    // number of directionl plots
	//nPlots = getNumber("Please insert the number of profile lines", 10);		// Number of profile lines
	dirSave = getDirectory("Please choose your desired destination directory to save the profile lines as tif files");
    theta = 180/nPlots;   // clockwise rotation angle
    selectImage(id_tobeRotated);
    P2P_dif_vector = newArray(nPlots);
    print("\\Clear");
    print(" ************ ");
	print("Peak Coordinates (corresponding to each profile line) are listed as follows :");
	print(" ");
	for (i=0; i<nPlots; i++) {
		current_rotated_Stack = getImageID;
		current_profile = getProfile;
		run("Plot Profile");   		
   		// Plot.create("Detecting Peaks", "Distance (nm)", "Gray Value", current_profile);    Plot.show;    //Alternative 
   		maxLocs= Array.findMaxima(current_profile, 1);
   		print("For Line # ", i ," :");
   		for (jj= 0; jj < maxLocs.length; jj++){
      		x= maxLocs[jj]; 
      		y = current_profile[x];
			x = (pw)*(x); 
      		y = y;
//      		print("x= ", x, " y= ", y);
      		toUnscaled(x, y);
      		makeOval(x-4, y-4 + 1, 8, 8);
      		run("Invert");
      	}
      	Peaks_difference = maxLocs[0] - maxLocs[1];
      	Peaks_difference = (pw)*(Peaks_difference);
      	Peaks_difference = abs(Peaks_difference);
      	if (Peaks_difference > 150) {	      	
      		P2P_dif_vector[i] = (Peaks_difference);
      		print("Peak-to-Peak Distance = ", P2P_dif_vector[i]);    	      	      	
      	}
      	else {
      		print("too short distance");
      	}
      	saveAs("tif", dirSave + Title_OriginaStack + "Profile-Number-" + pad(i));
      	close();
      	//wait(500);
      	
        ///// ROTATION
      	ChoiceRotate = 0;  // set to 1 if you prefer each rotation be done on the last 'previousely-rotated' image. 
      					   // By setting to 0, each step of rotation will be done on the very first image rather than the rotated one(s)
		if(ChoiceRotate==1) {
			selectImage(current_rotated_Stack);
			//run("Rotate... ", "angle=theta grid=1 interpolation=Bilinear");
			run("Rotate... ", "angle=theta grid=1 interpolation=None");
		}
		if(ChoiceRotate==0) {
			selectImage(id_tobeRotated);
			beta = (i+1)*theta;
			run("Rotate... ", "angle=beta grid=1 interpolation=None");
		}
		
	}
	
	P2P_dif_vector=Array.deleteValue(P2P_dif_vector, 0);
	//Array.show(P2P_dif_vector);
	Array.getStatistics(P2P_dif_vector, min, max, mean, stdDev);
	print(" "); 	print(" ************ "); 	print(" ");
	print("Minimum Individual Peak-to-Peak Distance = ", min, " nm"); print(" ");
	print("Maximum Individual Peak-to-Peak Distance = ", max, " nm"); print(" ");
	print("Average Individual Peak-to-Peak Distance = ", mean, " nm"); print(" ");
	print("Standard Individual Deviation of the Peak-to-Peak Distances = ", stdDev, " nm"); print(" ");
	print(" ************ "); print(" ");					
	print("All Profile Lines have been Saved in the Selected Folder!");

	// Plot the average of all profile lines
	ChoiceProfile = 0;  // Set to 1 if you want to plot the average of all profile lines, otherwise set to 0

	if 	(ChoiceProfile==1); {
		waitForUser("User Action Required!", "All Profile Lines have been Saved in the Selected Folder! Press OK to plot the average profile line");  //wait for user action
		selectImage(id_OriginaStack);
		run("Restore Selection");
    	// run("Clear Results");
		profile = getProfile();
		sum_profile = profile; 		   	
		for (i=1; i<nPlots; i++) {
			run("Rotate... ", "angle=theta grid=1 interpolation=Bilinear");
			profile = getProfile();
			//  sum_profile = sum_profile + profile :
				for (f=0 ; f<lengthOf(sum_profile);f++){ 
					sum_profile[f] = sum_profile[f] + profile[f]; 
					}
			selectImage(id_OriginaStack);
		}	
		print("Average of all Profile Lines is being shown . . ."); print(" ");
		avg_profile = newArray(sum_profile.length);
		for (h=0 ; h<lengthOf(sum_profile);h++){ 
				avg_profile[h] = sum_profile[h]/nPlots; 
		}	   
		x = newArray(avg_profile.length);
		y = newArray(avg_profile.length);
		for (j= 0; j < avg_profile.length; j++){
      		x[j] = (pw)*(j); 
      		y[j] = avg_profile[j];
      		}
  	 	Plot.create("Average Profile", "Distance (nm)", "Gray Value", x,y);  Plot.show;
	 	saveAs("tif", dirSave + "Average Profile" + Title_OriginaStack);
		// PEAK t PEAK DISTANCE FOR THE AVERAGE PROFILE LINE
		maxLocs= Array.findMaxima(avg_profile, 1); 		      			
		for (jj= 0; jj < maxLocs.length; jj++){	
 			x= maxLocs[jj]; 
   			y = avg_profile[x];
			x = (pw)*(x); 
   			y = y;
   			toUnscaled(x, y);
   			makeOval(x-4, y-4 + 1, 8, 8);
   			run("Invert");
   			}
		Peaks_difference = maxLocs[0] - maxLocs[1];
		Peaks_difference = (pw)*(Peaks_difference);
		Peaks_difference = abs(Peaks_difference);
		print("Peak-to-Peak Distance of Averaged Profile = ", Peaks_difference);
	}

	run("Close All");

  function pad(n) {
      n = toString(n);
      while (lengthOf(n)<3)
          n = "0"+n;
      return n;
  }


	print(" ************ "); print(" ");
    