function [vr, vval, stdval] = im2radial(img, centroid, rmax, varargin)
[rmin, nr] = init(varargin{:});
if isempty(nr), nr = (rmax-rmin)+1; end;

[xg, yg]=meshgrid(1:size(img, 2), 1:size(img, 1));
vrad=sqrt((xg-centroid(1)).^2+(yg-centroid(2)).^2);
vr=linspace(rmin,rmax,nr+1);
if exist('discretize')==5
indbin=discretize(vrad, vr);
else
    indbin=floor((vrad-rmin)/(rmax-rmin)*nr)+1;
end
for i=1:nr
vval(i)=mean(img(find(indbin(:)==i)));
stdval(i)=std(img(find(indbin(:)==i)));
end
vr(nr+1)=[];
end


function [rmin, nr] = init(varargin)
for i=2:2:nargin-1
	switch varargin{i-1}
	case 'N'
		nr=varargin{i};
	case 'MinRadius'
		rmin =varargin{i};
	end
end

if ~exist('nr', 'var'), nr=[]; end;
if ~exist('rmin', 'var'), rmin=1; end;

end

