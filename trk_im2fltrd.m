function [imgbw, imgfltrd, imgsgn] = trk_im2fltrd(img, varargin)
[areamin, areamax, threshold, radsmooth, radflt] = init(varargin{:});
imgsz=size(img);

imgt=adapthisteq(mat2gray(img));

if radsmooth>0
imgbkgrnd=im2blur(imgt,radsmooth);
imgt=double(imgt)-imgbkgrnd;
imgsgn=sign(imgt);
imgt=abs(imgt);
else

end

if radflt<0
    imgt(imgsgn>0)=0;
    radflt=-radflt;
end
if radflt>0
imgblr= im2blur(imgt,  radflt);
imgblr=imgblr(1:imgsz(1), 1:imgsz(2), :);
else
imgblr=imgt;
end 




imgbw=im2bw(imgblr/max(imgblr(:)), threshold+(1-threshold)*mean(imgblr(:))/max(imgblr(:)));

    
%figure, imagesc(imgbw);


imgfltrd=imgt;
end

function [areamin, areamax, threshold, radsmooth, radflt] = init(varargin)
for i=2:2:nargin
switch varargin{i-1}
case 'AreaMax'
areamax=varargin{i};
case 'AreaMin'
areamin=varargin{i};
case 'Threshold'
threshold=varargin{i};
case 'Smooth'
radsmooth=varargin{i};
case 'RadiusFilter'
radflt=varargin{i};
end
end

if ~exist('areamax', 'var'), areamax=1000; end;
if ~exist('areamin', 'var'), areamin=5; end;
if ~exist('threshold', 'var'), threshold =0.5; end;
if ~exist('radsmooth', 'var'), radsmooth=100; end;
if ~exist('radflt', 'var'), radflt=20; end;
end

