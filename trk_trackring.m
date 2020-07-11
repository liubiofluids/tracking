function [vcord] = trk_trackring(img, varargin)
[rrange, gusscrd, winsz] = init(varargin{:});
if isempty(gusscrd), gusscrd=.5*fliplr(size(img)); end
if isempty(winsz), winsz=fliplr(size(img)); end;
rectROI=[max([gusscrd-.5*winsz; ones(1,2)]), winsz];

    imgcrp=imcrop(img, rectROI);
    [center, radii, metric] = imfindcircles(imgcrp, rrange);
    figure,
    center=center+repmat(rectROI(1:2), size(center, 1), 1);
    vdisp=center-repmat(gusscrd, size(center, 1), 1);
    vdist=sqrt(sum(vdisp.^2, 2));
    indmin=find(vdist==min(vdist));
    vcord=center(indmin(1), :);
end


function [rrange, gusscrd, winsz] = init(varargin)
for i=2:2:nargin
    switch varargin{i-1}
        case 'rRange'
            rrange=varargin{i};
        case 'GuessCentroid'
            gusscrd=varargin{i};
        case 'WinSize'
            winsz=varargin{i};
        
    end
end

if  ~exist('rrange', 'var'), rrange=[5, 100]; end;
if  ~exist('gusscrd', 'var'), gusscrd=[]; end;
if  ~exist('winsz', 'var'), winsz=[]; end;
end

