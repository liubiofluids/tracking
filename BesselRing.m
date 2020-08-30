function [imgbs] = BesselRing(szimg, rad0, varargin)
[nj] = init(varargin{:});
j0n=2.4048;
imgbs=zeros(szimg);
[xg, yg] = meshgrid(1:size(imgbs, 2), 1:size(imgbs, 1));
xg=xg-mean(xg(:));
yg=yg-mean(yg(:));
rg= sqrt(xg.^2 + yg.^2);
imgbs=besselj(nj, rg*(j0n/rad0));
imgbs=(imgbs-min(imgbs(:)))/(max(imgbs(:))-min(imgbs(:)));
end

function [nj] = init(varargin)
for i=2:2:nargin
    switch varargin{i-1}
        case 'QuantumNumber'
            nj=varargin{i};
    end
end
if ~exist('nj', 'var'), nj=0; end;
end