function [imgdots] = imRing2Dots(img, rb, rs, thrshld)
%% convert ring image to spots, 
%% imgring: original image
%% rb: the radius for smoothing background.
%% rs: the radius for smoothing rings.
%% require im2blur.m
imgbkg = im2blur(img, rb);
imgblr= im2blur(abs(img-imgbkg), rs);
imgbkg = im2blur(imopen(imgblr, strel('disk', rb)), rb);

imagesc(imgblr);
%imgblr = imgblr-im2blur(imopen(imgblr, strel('disk', 5*rs)), rb);
imgblr = (imgblr-min(imgblr(:)))/(max(imgblr(:))-min(imgblr(:)));
imgdots = im2bw(imgblr, thrshld);


end