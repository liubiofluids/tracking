function [pcntr, msm]=trk_imRing2Center(img, xyrange, varargin)
[rrange, nr, gusscrd, winsz] = init(varargin{:});
if isempty(gusscrd), gusscrd=.5*fliplr(size(img)); end
if isempty(winsz), winsz=fliplr(size(img)); end;
rectROI=[max([gusscrd-.5*winsz; ones(1,2)]), winsz];
    imgcrp=imcrop(img, rectROI);

[xg, yg] = meshgrid(1:xyrange(1), 1:xyrange(2));
xcntr=xg-mean(xg(:))+.5*(size(imgcrp, 2)+1);
ycntr=yg-mean(yg(:))+.5*(size(imgcrp, 1)+1);
msm=zeros(size(xg));
for i=1:numel(msm)
[vr, vval, stdval]=trk_im2radial(imgcrp, [xcntr(i), ycntr(i)], rrange(2), 'MinRadius', rrange(1), 'N', nr);
msm(i)=sum(stdval./vval);
end
A = [ones(size(xg(:))), xg(:), yg(:)];
b = msm(:);
coeff = A\b;
Zfit = A*coeff;
%figure, imagesc([msm, reshape(Zfit, size(msm))]);
msm = msm-reshape(Zfit, size(msm));

[ip_y, ip_x] = func_findpeak2(-msm, 2);

pcntr(1)=interp1(1:xyrange(1), xcntr(1,:), ip_x);
pcntr(2)=interp1(1:xyrange(2), ycntr(:,1)', ip_y);
pcntr=pcntr+rectROI(1:2);
end

function [rrange, nr, gusscrd, winsz] = init(varargin)
for i=2:2:nargin
    switch varargin{i-1}
        case 'rRange'
            rrange=varargin{i};
        case 'N'
		    nr=varargin{i};
        case 'GuessCentroid'
            gusscrd=varargin{i};
        case 'WinSize'
            winsz=varargin{i};

    end
end
if ~exist('rrange', 'var'), rrange=[]; end;
if ~exist('nr', 'var'), nr=[]; end;
if  ~exist('gusscrd', 'var'), gusscrd=[]; end;
if  ~exist('winsz', 'var'), winsz=[]; end;

end
