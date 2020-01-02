%RunFindNuclei_Final

%{ 
RunFindNuclei_Final

The overaching goal of this script, together with FindNuclei_Final, 
NucleusFinder_Final, and FindS100B_Final, is to estimate the number of
glial cells present in an image of a section of the superior cervical ganglion.
 
The slices under analysis were stained with markers for MAP2 (red), S100B (green),
and DAPI (blue). These stain for neuron somata, glial somata, and cell
nuclei, respectively. As these images show, sympathetic glia are very densely
packed within the ganglion, and resolving the boundaries between individual
cells is near impossible. Instead, the program attempts to quantify the number of
S100B+ nuclei, which provides a strong estimate of the number of cells. The
consequent problem is that many glial nuclei are stacked on top of each other 
in close proximity, making it difficult for program and human alike to
distinguish individual cells.

This difficulty is resolved by estimating the median size of a single nucleus,
and dividing the total nuclear area by the that median size. From this
calculation, we can estimate the number of distinct glia cells.


Here is an overview of the program:
1) The user defines three critical thresholds:
greenThreshold: the minimum value for green signal that would qualify as a
S100B+ pixel
blueThreshold: the minimum value for green signal that would qualify as a
DAPI+ pixel
minNucleusSize: The smallest area of S100B+/DAPI+ colocalization that
could be considered a cell nucleus.

The values for these parameters depend on the size and intensity of the
images. greenThreshold varies according to the image. blueThreshold is usually around 200
(for a [0,255] color scheme). minNucleusSize is usually around 300, but
might be lower in younger slices.

2) The program reads each of the images in the folder, and saves an image
mask corresponding to indices of pixels whose green value exceeded the
user-defined threshold. This is performed by the function FindS100B_Final.

3) With the green mask prepared, the program now looks for pixels that are
both DAPI+ and S100B+. The FindNuclei_Final function locates nuclei
according to the masks and corresponding images created in step 2.

4) Once the DAPI+/S100B+ pixels have been identified, they are sorted into
connected components. Blobs of a size less than the user-defined threshold
minNucleusSize are excluded. Those reamining blobs should (mostly)
correspond to the locations of nuclei or clusters of nuclei. These clusters
will be called the "nuclear blobs" and the total area of the nuclear blobs 
will be called the "nuclear area".

5) The median size of the nuclear blobs should be a good estimate of the
size of a single nucleus. The user should verify this. With this
information in hand, the program will divide the nuclear area by the median
size of all of the nuclear blobs. This yields an estimate of the number of
distinct nuclei, which should correspond to the number of glial cells.


%}

%% RunFindNuclei_Final
%{
This program searches through a directory of images. In the process, the
program executes FindNuclei_Final, NucleusFinder_Final, and FindS100B_Final, all of which must
be in the top-level folder.

The images should be in a form where the red channel represents neuron
staining (i.e. Map2), green channel glial staining, and blue channel DAPI (
a nuclear marker).

RunFindNuclei_Final calls FindS100B_Final and FindNuclei_Final, and
FindNuclei Final calls NucleusFinder_Final
%}

%% User Controlled Parameters
greenThreshold = 40;
blueThreshold = 90;
minNucleusSize = 250;
directoryName = 'SHR SCG_8 weeks female_Rep 3';

%greenThreshold is user-selected cutoff for what constitutes a green pixel in the
%image. Pixels with a green channel value above thresh will be used. During
%the use of the program across multiple sets of images, the user may need
%to change the image multiple times.

%blueThreshold performs a similar function, but in determining DAPI+ pixels

%directoryName is the name of the folder that contain the images, for
%example:

%directoryName = 'SHR SCG_8 weeks female_Rep 3';



%%
[fileNames,meanIntensity,totalGreenIntensity,numberOfGreenPixels,allImages,greens,redAndGreenSimilarity] = FindS100B_Final(directoryName,greenThreshold);
%FindS100B_Final scans through the directory provided, opens and reads the
%images, and returns information about their intensity and location. 


%maxSize is the number of pixels in the image. All images we looked at were of size 2048x2048x3.
%meanPixels is the average number of green pixels above thresh across all
%images. Note that meanPixels does NOT weight for intensity.

maxSize = 2048*2048; 
meanPixels = mean(numberOfGreenPixels)/maxSize;

%%
[nucleusSize,nucleusArea,numCells,blues] = FindNuclei_Final(greens,allImages,blueThreshold,minNucleusSize);
%The above line will go through several other functions. If Matlab reports a bug
%in the above statement, it likely exists in one of the functions.


N_images = length(fileNames);

AllData = cell(N_images,8);
%AllData is a large variable that will keep track of several important
%pieces of information so that we can easily produce them on a table. This
%is important because the data will need to be exported as a .xlsx file,
%which can be read by a product called Excel (Microsoft Corp, Seattle), a deprecated
%statistics software package still used by some scientists.

AllData(:,1) = fileNames;
AllData(:,2:5) = num2cell([meanIntensity,totalGreenIntensity,numberOfGreenPixels,redAndGreenSimilarity]);
AllData(:,6:8) = num2cell([nucleusSize,nucleusArea,numCells]);

%The Columns of AllData are as follows:
%Column 1: filenames corresponding to each image
%Column 2: meanIntensity, that is, the average Green intensity of the image, that
%is, the total intensity of the green pixels divided by the size of the
%image (2048*2048)
%Column 3: The total intensity of the green channel (conveys the same information as
%Column 2)
%Column 4: Number of pixels with a green signal above the threshold
%Column 5: Measures the similarity between red and green. We used this to
%test for overlapping between channels in some of our earlier images. Use
%to check if the fluorophores representing the red and green channels have
%any risk of overlap.
%Column 6: Medium size of a "nucleus", i.e. a blue "blob". The median
%should correspond to the "true" size of a blue nucleus.
%Column 7: Total area covered by the nuclei
%Column 8: Estimated number of cells (total green area divided by the
%number of nuclei)

headers = {'fileNames','MeanIntensities','GreenIntensity','GreenPixels','RG_scores',...
    'nucleusSize','nucleusArea','numCells'};
XLT = cell2table(AllData,'VariableNames', headers);
xlName2 = strcat(directoryName,'_glia_',date,'.xlsx');
writetable(XLT,xlName2);

%toc;