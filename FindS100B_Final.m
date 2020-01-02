function [fileNames,meanIntensity,greenIntensity,greenPixels,allImages,greenImage,rg_simScores] = FindS100B_Final(dirName,threshold)
%RunS100B_Final: Determine the location of green pixels on the image, which
%should correspond to positie S100B signal, thereby providing the location
%of all glia cells. This function alone cannot calculate the number of glial
%cells, because the spatial overlap between the cells precludes segmenting
%the S100B signal.

%Inputs
%dirName: Directory of images that the program will iterate through.
%threshold: minimum pixel value for green that "counts" as S100B+

%Outputs
%fileNames: filename corresponding to each image
%meanIntensity: the average Green intensity of the image, that
%is, the total intensity of the green pixels divided by the size of the
%image (2048*2048)
%greenIntensity: the total intensity of the green channel 
%greenPixels: the number of pixels with a green signal above the threshold
%allImages: returns the full-size images from the analysis, in case the
%user wants to display them after the program has finished.
%greenImage: boolean array corresponding to S100B+ pixels, according to the
%threshold set by the user.
%rg_simscores: measures the similarity between red and green. We used this to
%test for overlapping between channels in some of our earlier images. Use
%to check if the fluorophores representing the red and green channels have
%any risk of overlap.


cd(dirName)
dirk = dir('*.tif');
N_images = numel(dirk);

fileNames = cell(N_images,1);
allImages = cell(N_images,1);
greenPixels = zeros(N_images,1);
greenIntensity = zeros(N_images,1);
greenImage = cell(N_images,1);
rg_simScores = zeros(N_images,1);

%This for-loop, and the many like it throughout the program, would better be
%implemented as a vectorization. Computational speed was not a significant factor for us
%(most analyses take only a few seconds).
for k = 1:N_images
    %Read the image
    imago = imread(dirk(k).name);

    %saves the image and filename
    allImages{k} = imago;
    fileNames{k} = dirk(k).name;
    G = imago(:,:,2);
    Gt = G >= threshold; %Threshold to remove noisy values
    G(Gt) = 0;
    
    %Store information before restarting the loop
    greenPixels(k) = nnz(G);
    greenIntensity(k) = sum(sum(G));
    greenImage{k} = Gt;
    rg_simScores(k) = ssim(imago(:,:,1),imago(:,:,2));
    
    %lower values = less similarity between red and green = better
    
    
%     side-by-side comparison of the original image and the pixels marked
%     as S100B+.
%     figure()
%     montage({imago,Gt})
%     
    cd ..
    
    %Create new folder if it doesn't already exist
    %pwd is the current file. In more complicated programs, using
    %this can be a very bad idea. For our purposes, this limited usage will
    %be acceptable.
    currentFolderName = pwd;
    newSubFolderName = strcat(dirName,' Greens');
    newSubFolder = [currentFolderName,'/',newSubFolderName];
    
    if ~exist(newSubFolder, 'dir')
        mkdir(newSubFolder);
    end
    
    cd(newSubFolderName)
    imwrite(Gt,strcat(fileNames{k}(1:end-4),'.png'))
    cd ..
    cd(dirName)
    
end
meanIntensity = greenIntensity./greenPixels; %We can do this outside of the loop
cd ..

%Save workspace
save(strcat(dirName,'-Green-',date));

end