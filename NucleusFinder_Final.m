function [nucleusSize,nucleusArea,numberOfGlia] = NucleusFinder_Final(B,min_size)
%Takes in a grayscale image of nuclei


%threshold for minimum value of Dapi that "counts". We are leveraging the
%hypersaturation of the blue channel that occurs in our images.

%% Detect Nuclei

%We begin by drawing all possible chunks/blobs in B (using conncomp),
%which can be of any size. These are stored in the struct CC, which
%includes the field 'PixelIdxList'. PixelIdxList is a cell array, where
%the kth element is a column vector containing the linear indices of all of
%the pixels in the kth blob.

%Most of these blobs are of size 1, making them of little importance. We
%need to filter them down by using size exclusion. We do this by
%calculating the length of each of the arrays in PixelIdxList ('lengths'),
%and thresholding them with 'min_size', producing 'longEnough'.
%'longEnough' which is a vector that contains the indices of PixelIdxList
%that have more points than our threshold, 'min_size'. We then change CC to
%only include these "real" pixel blobs, which correspond to nuclei or
%clusters of nuclei.

%Inputs:
%B: Matrix containing all blue&green pixels (according to our thresholds)
%that we will then attempt to assign to nuclei.
%min_size: minimum # of pixels needed to count as a real nucleus

%Outputs:
%nucleusSize: Median size of a blue "blob".
%nucleusArea: Perhaps more properly the "blue and green area", this area
%represents the total area covered by glial nuclei. Dividing this by the
%appoximate size of a single glial nucleus gives us a measurement of the
%number of glia.
%numberOfGlia: What we're really after. This is the appoximate count of how
%many glia are in the image.

%% Detect Nuclei
nhood = 1; %neighborhood for imclose, the smaller the number the closer two blobs need to be to be put together
CC = bwconncomp(B);
%struct containing the information from searching connections between the
%members of the boolean array.

lengths = cellfun('length', CC.PixelIdxList);
%CC has a cell array (PixelIdxList) of length CC.NumObjects that contains
%the indices of all of the pixels in it.


longEnough = find(lengths > min_size);
%Determine the indices of blobs large enough to qualify as putative nuclei

CC.PixelIdxList = CC.PixelIdxList(longEnough);
CC.NumObjects = length(longEnough);
%Excise blobs that do not fit our size criterion

clusterSizes = cellfun('length', CC.PixelIdxList);
%Determine the size of the blobs that were determined to be sufficiently
%large

nucleusSize = median(clusterSizes);
nucleusArea = sum(clusterSizes); %total area of the glia nucelei's pixel
numberOfGlia = nucleusArea/nucleusSize;

figure()
imshow(labelmatrix(CC)>0)

end

