function [vcord, imgtracked, vdark, varargout]=trk_trackCluster(img, varargin)

[guesscentroid, threshold, areamin, areamax, boolshow, winsz0,  radflt, radJ, bcont, cmask]=init(varargin{:});

gusscord=guesscentroid;
winsz=winsz0;
szimg=size(img);
if isempty(winsz)
winsz=szimg([2,1]);
end
if isempty(gusscord)
gusscord=szimg([2,1])*.5;
end
roirect=floor([max([ones(1,2); gusscord-.5*winsz+.5]), min([winsz(:)'; fliplr(size(img))-(gusscord-.5*winsz)+.5])]);

imgcrp=imcrop(img, roirect);
%[imgbw, imgfltrd, imgsgn]=im2fltrd(imgcrp, 'Smooth', radsmooth, 'RadiusFilter', radflt, 'Threshold', threshold(1), 'Signed', fsgn);
imgfltrd = im2trackable (imgcrp, 'BesselRadius', radJ);
%figure, imagesc(imgfltrd); 
imgblrd = im2blur(imgfltrd, radflt);
%figure, imagesc(imgblrd); 
[xg, yg] = meshgrid(1:size(imgblrd, 2), 1:size(imgblrd, 1));
imgcntr = ones(size(imgblrd));
if ~isempty(cmask)
for ic=1:length(cmask)
    vin = inpolygon(xg(:)+roirect(1), yg(:)+roirect(2), cmask{ic}(:, 1), cmask{ic}(:,2));
    imgcntr(vin)=0;
end
end

imgbw = im2bw((imgblrd-min(imgblrd(:))).*imgcntr/(max(imgblrd(:))-min(imgblrd(:))), threshold(1));

%if ~isempty(cmask)

%    xq = xg(imgbw>0);
%    yq = yg(imgbw>0);
    
%    for kk=1:length(cmask)
%        in = inpolygon(xq+roirect(1), yq+roirect(2), cmask{kk}(:, 1), cmask{kk}(:,2));
%        xq(in)=[];
%        yq(in)=[];
%    end
%    imgbw=zeros(size(imgbw));

%    for kk=1:length(xq)
%        imgbw(yq(kk), xq(kk))=1;
%   end
%
 
%end
        
%figure, imagesc(imgbw); return;
[rectcntr, crdtrc, imgcntr]=TrackCenter(imgbw, areamin, areamax);

if ~isempty(rectcntr)
    imgfcrp=imcrop(imgfltrd, rectcntr);
    imglcrp=imcrop(imgblrd, rectcntr);
    img1crp=imcrop(double(imgcrp), rectcntr); 
    imgbcrp=imcrop(imgcntr, rectcntr);
else
    imgfcrp=imgfltrd;
    imglcrp=imgblrd;
    img1crp=imgcrp;
    imgbcrp=imgcntr;
end

if bcont
    vdark=[(mean(imglcrp(find(imgbcrp>0)))-mean(imglcrp(find(imgbcrp<0.1))))/(mean(imglcrp(find(imgbcrp>0)))+mean(imglcrp(find(imgbcrp<0.1)))), ...
        std(img1crp(find(imgbcrp>0)))];
else
    vdark=[mean(imgfcrp(find(imgbcrp>0))), std(img1crp(find(imgbcrp>0)))];
end

imgtracked=zeros(size(img,1), size(img,2));
imgtracked(rectcntr(2)+roirect(2):rectcntr(2)+roirect(2)-1+size(imgbcrp,1), rectcntr(1)+roirect(1):rectcntr(1)+roirect(1)-1+size(imgbcrp,2))=imgbcrp;
[xg, yg]=meshgrid(1:size(imgtracked, 2), 1:size(imgtracked, 1));

indtr=find(imgtracked>0);
vcord=[mean(xg(indtr)), mean(yg(indtr))];

[B,L] = bwboundaries(imgtracked,'noholes');

if boolshow
hold off;

imagesc(img); hold on;
for k = 1:length(B)
   boundary = B{k};
   plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
end

figure(gcf); pause(0.1);
end


end

function [guesscentroid, threshold, areamin, areamax, boolshow, winsz, radflt, radJ, bcont, cmask] = init(varargin)
% Brightness is [10,22]
% Areamin is 64
% Threshold is .5
% Guess centroid is the middel of imgraw by default
% Step of pixel is 2

for i=2:2:nargin
switch varargin{i-1}
case 'Threshold'
threshold=varargin{i};
case 'Areamin'
areamin=varargin{i};
case 'Areamax'
areamax=varargin{i};
case 'GuessCentroid'
guesscentroid=varargin{i};
case 'ShowImage'
boolshow=varargin{i};
case 'WindowSize'
winsz=varargin{i};
case 'RadiusFilter'
radflt=varargin{i};
    case 'BesselRadius'
        radJ=varargin{i};
    case 'Contrast'
        bcont=varargin{i};
    case 'Mask'
        cmask=varargin{i};
end
end

if ~exist('threshold', 'var'), threshold=.25; end;
if ~exist('areamin', 'var'), areamin=48; end;
if ~exist('guesscentroid', 'var'), guesscentroid=[]; end; 
if ~exist('boolshow', 'var'), boolshow=0; end;
if ~exist('winsz', 'var'), winsz=[]; end;
if ~exist('areamax', 'var'), areamax=10000; end;
if ~exist('radflt', 'var'), radflt=10; end;
if ~exist('radJ', 'var'), radJ=3; end;
if ~exist('bcont', 'var'), bcont=0; end;
if ~exist('cmask', 'var'), cmask=[]; end;

if numel(threshold)<2
    threshold=cat(1, threshold, threshold); 
end;
end




function [rectcntr, crdtrc, imgcntr]=TrackCenter(imgbw, areamin, areamax)
[labeled, n] = bwlabel(imgbw, 4);
graindata=regionprops(labeled);
szimg=size(imgbw);
crdcntr=.5*szimg([2,1]);
dmin=2;
rectcntr=[];
crdtrc=[];
imin=0;
for i=1:n

if graindata(i).Area>areamin && graindata(i).Area<areamax
d=norm((graindata(i).Centroid-crdcntr)./crdcntr);
if d<dmin
rectcntr=floor(graindata(i).BoundingBox);
crdtrc=graindata(i).Centroid;
imin=i;
dmin=d;
end
end
end

imgcntr=zeros(size(labeled));
if imin>0
imgcntr(find(labeled==imin))=1;
end

end

function [darkrel, imgt]=TargetDarkness(imgfltrd, imgraw, imgsgn, varargin)
[threshold] = initt(varargin{:});
szimg=size(imgfltrd);
roiimg=floor([.25*szimg([2,1]), .5*szimg([2,1])]);
imgblr=imfilter(imgfltrd, fspecial('gaussian',  5, 3));
imgblr=(imgblr-min(imgblr(:)))/(max(imgblr(:))-min(imgblr(:)));
imgbw=im2bw(imgblr, mean(imgblr(:))+threshold*max((imgblr(:))-mean(imgblr(:))));
imgtmpl=zeros(size(imgbw));
imgbwcrp=imcrop(imgbw, roiimg);
imgtmpl(roiimg(2):roiimg(2)+size(imgbwcrp,1)-1, roiimg(1):roiimg(1)+size(imgbwcrp,2)-1)=imgbwcrp;
[rectcntr, crdtrc, imgt]=TrackCenter(imgtmpl, 4, 10000);
imgmid=imgt.*imgraw;
imgsur=(1-imgt).*imgraw;
sgndark=sign(mean(imgmid(find(imgmid>0)))-mean(imgsur(find(imgsur>0))));


imgbw=imgbw.*(imgsgn*sgndark);
imgbw(find(imgbw<0))=0;
[rectcntr, crdtrc, imgt]=TrackCenter(imgbw, 4, 10000);
imgmid=imgbw.*imgraw;
imgsur=(1-imgbw).*imgraw;
cmid=mean(imgmid(find(imgmid>0)));
csur=mean(imgsur(find(imgsur>0)));
darkrel=(cmid-csur)/mean(imgraw(:));

    function [threshold] = initt(varargin)
        for i=2:2:nargin
            switch varargin{i-1}
                case 'Threshold'
                    threshold=varargin{i};
            end
        end
        if ~exist('threshold', 'var'), threshold=.25; end;
    end

end

