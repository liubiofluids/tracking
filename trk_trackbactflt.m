function [vcord, imgtracked, vdark, varargout]=trk_trackbactflt(img, varargin)
[guesscentroid, threshold, areamin, areamax, boolshow, boolshape, stppix, winsz0, radsmooth, radflt, bbrght, fsgn, vpos, bnout, cmask]=init(varargin{:});
varargout{1}=[];
gusscord=guesscentroid;
winsz=winsz0;

szimg=size(img);
if isempty(winsz)
winsz=szimg([2,1]);
end
if winsz(1)==0
    vcord=[0, 0];
    vdark=0;
    imgtracked=img;
    return;
end
if isempty(gusscord)
gusscord=szimg([2,1])*.5;
end
if ~isempty(vpos)
gusscord=vpos(i, :);
end
roirect=floor([max([ones(1,2); gusscord-.5*winsz+.5]), min([winsz(:)'; fliplr(size(img))-(gusscord-.5*winsz)+.5])]);
imgcrp=imcrop(img, roirect);
imgmask=zeros(size(img));
for k=1:length(cmask)
maskk=poly2mask(cmask{k}(:,1), cmask{k}(:,2), size(img, 1), size(img, 2));
imgmask=imgmask|maskk;
end
imgmaskcrp=imcrop(imgmask, roirect);
try 
    imgcrp=regionfill(imgcrp, imgmaskcrp);
catch rferr
    imgcrp(imgmaskcrp>0)=mean(imgcrp(:));
end

[imgbw, imgfltrd, imgsgn]=trk_im2fltrd(imgcrp, 'Smooth', radsmooth, 'RadiusFilter', radflt, 'Threshold', threshold(1), 'Signed', fsgn);
imgbw(imgsgn==bbrght)=0;
%figure, imagesc(imgcrp);
[rectcntr, crdtrc]=TrackCenter(imgbw&(1-imgmaskcrp), areamin, areamax);
imgfcrp=imcrop(imgfltrd, rectcntr);
img1crp=imcrop(double(imgcrp), rectcntr); 
imgscrp=imcrop(imgsgn, rectcntr);
[darkrel, imgt]=TargetDarkness(imgfcrp, img1crp, imgscrp, 'Threshold', threshold(2));
vdark=darkrel;
imgtracked=zeros(size(img,1), size(img,2));

imgtracked(rectcntr(2)+roirect(2):rectcntr(2)+roirect(2)-1+size(imgt,1), rectcntr(1)+roirect(1):rectcntr(1)+roirect(1)-1+size(imgt,2))=imgt;
[xg, yg]=meshgrid(1:size(imgtracked, 2), 1:size(imgtracked, 1));

indtr=find(imgtracked>0);
vcord=[mean(xg(indtr)), mean(yg(indtr))];

centroid=vcord;
if boolshape
%    imagesc(imgbw); return; 
[ CordArr, MajorAxe, MajorDir] = BodyCtrLineArea(imgtracked, stppix);
varargout{1}=struct('CordArr', CordArr, 'MajorAxe', MajorAxe, 'MajorDir', MajorDir, 'centroid', centroid);
end



end

function [guesscentroid, threshold, areamin, areamax, boolshow, boolshape, stppix, winsz, radsmooth, radflt, bbrght, fsgn, vpos, bnout, cmask] = init(varargin)
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
case 'StepPixel'
stppix=varargin{i};
case 'WindowSize'
winsz=varargin{i};
case 'CellShape'
boolshape=varargin{i};
case 'Smooth'
radsmooth=varargin{i};
case 'RadiusFilter'
radflt=varargin{i};
case 'Position'
vpos=varargin{i};
case 'BrightOnly'
bbrght=varargin{i};
    case 'Signed'
        fsgn=varargin{i};
    case 'NoOut'
        bnout=varargin{i};
case 'Mask'
	cmask=varargin{i};
end
end

if ~exist('threshold', 'var'), threshold=.5; end;
if ~exist('areamin', 'var'), areamin=48; end;
if ~exist('guesscentroid', 'var'), guesscentroid=[]; end; 
if ~exist('boolshow', 'var'), boolshow=0; end;
if ~exist('stppix', 'var'), stppix=2; end;
if ~exist('winsz', 'var'), winsz=[]; end;
if ~exist('boolshape', 'var'), boolshape=0; end;
if ~exist('radsmooth', 'var'), radsmooth=100; end;
if ~exist('radflt', 'var'), radflt=20; end;
if ~exist('bbrght', 'var'), bbrght=0 ;end;
if ~exist('fsgn', 'var'), fsgn=0; end;
if ~exist('areamax', 'var'), areamax=10000; end;
if ~exist('vpos', 'var'), vpos=[]; end;
if ~exist('bnout', 'var'), bnout=0; end;
	    if ~exist('cmask', 'var'), cmask={}; end;
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
