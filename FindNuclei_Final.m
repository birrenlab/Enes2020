function [nucleusSize,nucleusArea,numberOfGlia,blues] = FindNuclei_Final(greens,images,blueThreshold,minNucleusSize)
%FindNuclei_Final

%Determines the sites of nuclei, which can then be used to estimate the
%number of individual glial cells. Also excludes based on size. 

%Inputs:

%blueThreshold: minimum value for a pixel to count as a member of the glial nucleus
%greens: Cell array, with each cell containing a logical image
%detailing where there was sufficient green signal. The overlap of this
%green signal and the DAPI signal can be used to distinguish where glial
%nuclei are present.
%images: original images, as arrays.

%Outputs:

%nucleusSize: Median size of a blue "blob".
%nucleusArea: Perhaps more properly the "blue and green area", this area
%represents the total area covered by glial nuclei. Dividing this by the
%appoximate size of a single glial nucleus gives us a measurement of the
%number of glia.
%numberOfGlia: What we're really after. This is the appoximate count of how
%many glia are in the image.
%blues: boolean array containing the locations of the confirmed nuclei

blues = cell(size(images));
N_images = length(images);
nucleusSize = zeros(size(images));
nucleusArea = zeros(size(images));
numberOfGlia = zeros(size(images));

for l = 1:N_images
    temp = images{l};
    B = temp(:,:,3);
    %Only look at the blue channel
    
    
    B2 = B > blueThreshold;
    %Threshold to see which pixels are "blue enough"
    
    figure()
    imshow(B2)
    
    B3 = B2 & greens{l};
    figure()
    imshow(B3)
    %Determine intersection of pixels determined to be part of glia
    %("greens") and those that are nuclei ("B2").
    
    blues{l} = B3;
    %Saves the image of only the blue points for viewing later
    
    [nucleusSize(l),nucleusArea(l),numberOfGlia(l)] = NucleusFinder_Final(B3,minNucleusSize);
    %Lanches the next function, which calculates the properties of the
    %nuclei
    
    
    %figure()
    %imshow(B3)
    %The two lines above offer the user visual confirmation that the
    %program has identified the nuclei properly
end

end

